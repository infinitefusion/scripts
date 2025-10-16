

class Game_Event
  def player_near_event?(radius)
    dx = $game_player.x - @x
    dy = $game_player.y - @y
    distance = Math.sqrt(dx * dx + dy * dy)
    return distance <= radius
  end

  def playerNextToEvent?
    return player_near_event?(1)
  end
end

class PokemonTemp
  attr_accessor :overworld_pokemon_flee
end



#fleeDelay: The time (in seconds) you need to wait between steps for the Pokemon not to flee
def checkOWPokemonFlee(mapId, eventId, fleeDelay)
  $PokemonTemp.overworld_pokemon_flee ||= {}
  key = "#{mapId}_#{eventId}"
  current_time = Time.now.to_f
  last_time = $PokemonTemp.overworld_pokemon_flee[key]
  if last_time
    time_past = current_time - last_time
    echoln "last time: #{last_time}, current time: #{current_time}, time past: #{time_past}"

    if time_past < fleeDelay
      $PokemonTemp.overworld_pokemon_flee[key] = nil
      return true
    else
      $PokemonTemp.overworld_pokemon_flee[key] = current_time
      return false
    end
  else
    # First time seeing this event
    $PokemonTemp.overworld_pokemon_flee[key] = current_time
    echoln "start tracking"
    return false
  end
end

#To be called from an event
#
#- flee_delay in seconds (can be fractions). The higher, the more skittish the Pokemon is
# It's the time you need to stand still for the Pokemon not to flee.
#
#- radius: the circle around the Pokemon from where it will start detecting you

def overworldPokemonBehaviorManual(species:,level:,radius:,flee_delay:)
  event = $MapFactory.getMap(@map_id).events[@event_id]

  if event.player_near_event?(radius)
      if $game_player.moving?
        should_flee = checkOWPokemonFlee(@map_id,@event_id,flee_delay)
        should_flee = true if pbFacingEachOther(event,$game_player)
        if should_flee
          pbSetSelfSwitch(@event_id,"B",true)
        else
          if event.playerNextToEvent?
            playAnimation(Settings::EXCLAMATION_ANIMATION_ID,event.x, event.y)
            event.turn_toward_player
            playCry(species)
            pbWildBattle(species,level)
            pbSetEventTime
            event.erase
          end
        end
      end
  end
end

#Called from automatically spawned overworld Pokemon - species and level is obtained from name

def overworldPokemonBehavior()
  event = $MapFactory.getMap(@map_id).events[@event_id]
  parsed_event_name = event.id.split("_")
  species_id = parsed_event_name[1].to_sym
  level = parsed_event_name[2].to_i
  radius = calculate_ow_pokemon_sight_radius(species_id)
  flee_delay = calculate_ow_pokemon_flee_delay(species_id)
  overworldPokemonBehaviorManual(species: species_id, level: level, radius: radius, flee_delay: flee_delay)
end

#The harder the pokemon is to catch, the more skittish it is (shorter flee delay)
def calculate_ow_pokemon_flee_delay(species_id)
  min_delay = 1
  max_delay = 4
  catch_rate = GameData::Species.get(species_id).catch_rate
  delay = max_delay - ((catch_rate - 1) / 254.0) * (max_delay - min_delay)
  return delay.round
end

#The rarer the Pokemon, the more skittish it is (larger sight radius)
def calculate_ow_pokemon_sight_radius(species_id)
  min_radius = 2
  max_radius = 6
  catch_rate = GameData::Species.get(species_id).catch_rate
  radius = min_radius + ((255 - catch_rate) / 254.0) * (max_radius - min_radius)
  return radius.round
end
