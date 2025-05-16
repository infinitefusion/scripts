SaveData.register(:weather) do
  ensure_class :GameWeather
  save_value { $game_weather }
  load_value { |value|
    $game_weather = value || GameWeather.new
    $game_weather.update_neighbor_map
    $game_weather.initialize_weather unless $game_weather.current_weather
    # to account for new maps added
  }
  new_game_value { GameWeather.new }
end

class GameWeather
  attr_accessor :current_weather
  CHANCE_OF_RAIN = 10 #/100
  CHANCE_OF_SUNNY = 5 #/100
  CHANCE_OF_WINDY = 5 #/100

  MAX_INTENSITY_ON_NEW_WEATHER = 4

  CHANCES_OF_INTENSITY_INCREASE = 25 # /100
  CHANCES_OF_INTENSITY_DECREASE = 50 # /100

  BASE_CHANCES_OF_WEATHER_END = 5 #/100 - For a weather intensity of 10. Chances increase the lower the intensity is
  BASE_CHANCES_OF_WEATHER_MOVE = 10
  DEBUG_PROPAGATION = false

  COLD_MAPS = [444] #Rain is snow on that map (shoal cave)
  SANDSTORM_MAPS = [555] #Always sandstorm, doesn't spread
  SOOT_MAPS = []  #Always soot, doesn't spread
  NO_WIND_MAPS = [989] #Sootopolis

  def map_current_weather_type(map_id)
    map_weather = @current_weather[map_id]
    return map_weather[0] if map_weather
  end

  def initialize

    # Similar to roaming legendaries: A hash of all the maps accessible from one map
    @neighbors_maps = generate_neighbor_map_from_town_map
    initialize_weather
    echoln @neighbors_maps
  end

  def initialize_weather
    weather = {}
    @neighbors_maps.keys.each { |map_id|
      weather[map_id] = adjust_weather_for_neighbor_conflict(map_id, roll_for_new_weather)
    }
    print_current_weather
    @current_weather = weather
  end

  def update_weather()
    new_weather = @current_weather.dup
    new_weather.clone.each_key do |map_id|
      propagate_map_weather(map_id, new_weather)
    end

    @current_weather.each do |map_id, (type, intensity)|
      if SANDSTORM_MAPS.include?(map_id)
        new_weather[map_id] = get_updated_weather(:Sandstorm, 8,map_id)
        next
      end

      case type
      when :None
        updated_weather = adjust_weather_for_neighbor_conflict(map_id, roll_for_new_weather)
        updated_weather = get_updated_weather(updated_weather[0],updated_weather[1],map_id)
      else
        if roll_for_weather_end(intensity)
          if intensity >= 2
            new_weather[map_id] = get_updated_weather(@current_weather[0], 1,map_id)
          else
            new_weather[map_id] = get_updated_weather(:None, 0,map_id)
          end
          if roll_for_weather_move
            propagate_weather_on_move(map_id, type, intensity, new_weather)
            new_weather[map_id] = get_updated_weather(:None, 0,map_id)
            next
          end
          next
        end

        intensity -= 1 if roll_for_weather_decrease
        intensity += 1 if roll_for_weather_increase
        updated_weather = get_updated_weather(type, intensity,map_id)
      end
      new_weather[map_id] = updated_weather
    end



    update_overworld_weather($game_map.map_id)
    @current_weather = new_weather
    print_current_weather()
  end

  def get_updated_weather(type,intensity,map_id)
    if COLD_MAPS.include?(map_id)
      type = :Snow if type == :Rain
      type = :None if type == :Sunny
    end
    if SOOT_MAPS.include?(map_id)
      type = :SootRain if type == :Rain
    end
    return [type, intensity]
  end

  def propagate_map_weather(map_id, new_weather)
    return if !new_weather[map_id]
    type, intensity = new_weather[map_id]
    return if type == :None || intensity <= 1

    mapinfos = pbLoadMapInfos
    source_map_name = mapinfos[map_id].name rescue "Map #{map_id}"

    neighbors = @neighbors_maps[map_id] || []
    neighbors.each do |neighbor_id|
      next if is_indoor_map?(neighbor_id)

      neighbor_type, neighbor_intensity = new_weather[neighbor_id] || [:None, 0]
      neighbor_map_name = mapinfos[neighbor_id].name rescue "Map #{neighbor_id}"

      # Skip if neighbor has same or stronger of the same type
      if neighbor_type == type && neighbor_intensity >= intensity
        echoln "[SKIP] #{source_map_name} → #{neighbor_map_name}: same weather type with higher or equal intensity"  if DEBUG_PROPAGATION
        next
      end

      propagation_chance = intensity * 10 # 1–10 → 7%–70%
      roll = rand(100)
      echoln "[ROLL] Propagation from #{source_map_name} (#{type},#{intensity}) to #{neighbor_map_name} (#{neighbor_type},#{neighbor_intensity}) - Chance: #{propagation_chance} percent | Rolled: #{roll}" if DEBUG_PROPAGATION

      if roll < propagation_chance
        result_type = resolve_weather_interaction(type, neighbor_type, intensity, neighbor_intensity)
        result_type = :None if !result_type
        result_intensity = [intensity - 1, 1].max
        echoln "  → Success! #{neighbor_map_name} now has #{result_type} (#{result_intensity})" if DEBUG_PROPAGATION
        new_weather[neighbor_id] = [result_type, result_intensity]
      else
        echoln "  → Failed to propagate to #{neighbor_map_name}" if DEBUG_PROPAGATION
      end
    end
  end

  def adjust_weather_for_neighbor_conflict(map_id, weather)
    type, intensity = weather
    return weather unless type == :Rain || type == :Sunny

    neighbors = @neighbors_maps[map_id] || []
    neighbors.each do |neighbor_id|
      neighbor_type, _ = @current_weather[neighbor_id] || [:None, 0]
      if (type == :Rain && neighbor_type == :Sunny) || (type == :Sunny && neighbor_type == :Rain)
        echoln "  → Weather at map #{map_id} changed from #{type} to Fog due to neighbor conflict with #{neighbor_type}" if DEBUG_PROPAGATION
        return [:Fog, intensity]
      end
    end
    return weather
  end

  def propagate_weather_on_move(map_id, type, intensity, new_weather)
    return if type == :None || intensity <= 1

    neighbors = @neighbors_maps[map_id] || []
    mapinfos = pbLoadMapInfos
    source_map_name = mapinfos[map_id].name rescue "Map #{map_id}"

    neighbors.each do |neighbor_id|
      next if is_indoor_map?(neighbor_id)

      neighbor_type, neighbor_intensity = new_weather[neighbor_id] || [:None, 0]
      neighbor_map_name = mapinfos[neighbor_id].name rescue "Map #{neighbor_id}"

      # Same weather type already stronger or equal? Skip.
      if neighbor_type == type && neighbor_intensity >= intensity
        echoln "[SKIP-END] #{source_map_name} → #{neighbor_map_name}: same weather type with higher or equal intensity" if DEBUG_PROPAGATION
        next
      end

      # Boost propagation chance on end-of-life: say 70% base, scaled by intensity
      base_chance = 70
      propagation_chance = base_chance + (intensity * 5)
      propagation_chance = [propagation_chance, 95].min
      roll = rand(100)

      echoln "[ROLL-END] End-weather push from #{source_map_name} (#{type},#{intensity}) to #{neighbor_map_name} - Chance: #{propagation_chance} percent | Rolled: #{roll}" if DEBUG_PROPAGATION

      if roll < propagation_chance
        result_type = resolve_weather_interaction(type, neighbor_type, intensity, neighbor_intensity)
        result_intensity = [intensity - 1, 1].max
        echoln "  → End propagation success! #{neighbor_map_name} now has #{result_type} (#{result_intensity})" if DEBUG_PROPAGATION
        new_weather[neighbor_id] = get_updated_weather(result_type, result_intensity,map_id)
      else
        echoln "  → End propagation failed to reach #{neighbor_map_name}" if DEBUG_PROPAGATION
      end
    end
  end

  def resolve_weather_interaction(incoming, existing, incoming_intensity, existing_intensity)
    echoln incoming
    echoln existing

    return incoming if existing == :None
    return :Fog if incoming == :Rain && existing == :Sunny
    return :Fog if incoming == :Sunny && existing == :Rain

    if incoming == :Rain && existing == :StrongWinds
      return :Storm if incoming_intensity >= 4 || existing_intensity >= 4
    end
    return incoming
  end

  def print_current_weather()
    mapinfos = pbLoadMapInfos
    echoln "Current weather :"
    @current_weather.each do |map_id, value|
      game_map = mapinfos[map_id]
      if game_map
        map_name = mapinfos[map_id].name
      else
        map_name = map_id
      end

      echoln "  #{map_name} : #{value}"
    end

  end

  def roll_for_weather_end(current_intensity)
    chances = BASE_CHANCES_OF_WEATHER_END
    chances += (10 - current_intensity) * 5
    return rand(100) <= chances
  end

  def roll_for_weather_move
    return rand(100) <= BASE_CHANCES_OF_WEATHER_MOVE
  end

  def roll_for_weather_increase
    return rand(100) <= CHANCES_OF_INTENSITY_INCREASE
  end

  def roll_for_weather_decrease
    return rand(100) <= CHANCES_OF_INTENSITY_DECREASE
  end

  def roll_for_new_weather
    intensity = rand(MAX_INTENSITY_ON_NEW_WEATHER) + 1
    roll = rand(100)
    if roll < CHANCE_OF_RAIN
      return [:Rain, intensity]
    elsif roll < CHANCE_OF_RAIN + CHANCE_OF_SUNNY
      return [:Sunny, intensity]
    elsif roll < CHANCE_OF_RAIN + CHANCE_OF_SUNNY + CHANCE_OF_WINDY
      return [:StrongWinds, intensity]
    else
      return [:None, 0]
    end
  end

end