class OverworldPokemonEvent < Game_Event

  attr_accessor :species
  attr_accessor :level

  attr_accessor :behavior_roaming
  attr_accessor :behavior_noticed

  attr_accessor :detection_radius
  attr_accessor :pokemon

  def setup_pokemon(species, level, terrain, behavior_roaming=nil, behavior_noticed=nil)
    @species = species
    @level = level
    @behavior_roaming = behavior_roaming if behavior_roaming
    @behavior_noticed = behavior_noticed if behavior_noticed
    species_data = GameData::Species.get(@species)

    @pokemon = Pokemon.new(species, level)
    @behavior_species = getBehaviorSpecies(species_data)


    unless behavior_roaming
      @behavior_roaming = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_roaming]
      @behavior_roaming = :random unless @behavior_roaming
    end
    unless behavior_noticed
      @behavior_noticed = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_noticed]
      @behavior_noticed = :normal unless @behavior_noticed
    end

    default_move_speed = calculate_value_from_stat(species_data, :SPEED, 1, 4)
    @roaming_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_move_speed] || default_move_speed
    @noticed_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_move_speed] || default_move_speed

    default_frequency = calculate_value_from_stat(species_data, :ATTACK, 1, 5)
    @roaming_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_frequency] || default_frequency
    @noticed_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_frequency] || default_frequency

    @detection_radius = calculate_ow_pokemon_sight_radius(species_data)

    @current_state = :ROAMING # Possible values: :ROAMING, :NOTICED_PLAYER, :FLEEING

    @deleted = false

    #@event.name = "OW/#{species.to_s}/#{level.to_s}"

    initialize_sprite(terrain)
    @roaming_sprite = @character_name
    @is_flying = @character_name == @flying_sprite
    @step_anime = @is_flying
    @always_on_top = @is_flying
    if terrain == :Water
      unless @is_flying
        self.forced_bush_depth = 20
        self.calculate_bush_depth
      end
    end

    if @pokemon.shiny?
      pbSEPlay("shiny", 60)
      playAnimation(Settings::SPARKLE_SHORT_ANIMATION_ID, @x, @y)
    end
    set_roaming_movement
  end

  def getBehaviorSpecies(species_data)
    if isSpeciesFusion(@species)
      return species_data.get_head_species_symbol
    end
    return @species
  end

  def initialize_sprite(terrain)
    @land_sprite = getOverworldLandPath
    @flying_sprite = getOverworldFlyingPath
    @noticed_sprite = getOverworldNoticedPath


    if terrain == :Water && @flying_sprite
      @character_name = @flying_sprite
    else
      if @land_sprite
        @character_name = @land_sprite
      elsif @flying_sprite
        @character_name = @flying_sprite
      end
    end
  end

  def get_current_state
    return @current_state
  end

  def notice_player
    @current_state = :NOTICED_PLAYER
  end

  def delete
    $PokemonTemp.overworld_pokemon_on_map.delete(self)
    @deleted = true
  end

  def deleted?
    return @deleted
  end

  ####
  # ACTIONS
  # ###
  def overworldPokemonBattle
    return if $PokemonTemp.prevent_ow_battles
    return if instance_variable_get(:@_triggered)
    instance_variable_set(:@_triggered, true)
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    turn_toward_player
    playCry(@species)

    $PokemonTemp.overworld_wild_battle_participants = [] if !$PokemonTemp.overworld_wild_battle_participants
    $PokemonTemp.overworld_wild_battle_participants << @pokemon
    pbWait(8)
    trigger_overworld_wild_battle
    despawn
    return
  end


  #####
  # Behaviors
  #####
  def noticed_state_different_from_roaming
    return false if @behavior_noticed == :normal && @behavior_roaming == :random
    return false if @behavior_noticed == :still && @behavior_roaming == :still
    return true
  end

  def playDetectPlayerAnimation
    return unless @current_state == :ROAMING
    return unless noticed_state_different_from_roaming()

    if @behavior_noticed == :curious
      playAnimation(Settings::QUESTION_MARK_ANIMATION_ID, @x, @y)
    elsif @behavior_noticed == :aggressive
      playAnimation(Settings::ANGRY_ANIMATION_ID, @x, @y)
    else
      playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    end
  end

  def update_behavior()
    return if @opacity == 0
    if player_near_event?(@detection_radius)
      if !$game_player.moving?
        if playerNextToEvent? # Battle
          overworldPokemonBattle
        else
          # check for noticed
          if @current_state == :ROAMING
            if check_detect_trainer
              playDetectPlayerAnimation
              update_state(:NOTICED_PLAYER)
            end
          elsif @current_state == :NOTICED_PLAYER
            unless player_near_event?(@detection_radius)
              update_state(@current_state = :ROAMING)
            end
          end
        end
      end
    else
      if @current_state != :ROAMING
        echoln "setting back to roaming"
        update_state(:ROAMING)
      end
    end
  end

  def turn_generic(*args)
    super(*args)

  end

  def update_state(new_state)
    @current_state = new_state
    update_movement_type
    set_sprite_to_current_state
  end

  def update_movement_type
    case @current_state
    when :ROAMING
      set_roaming_movement
    when :NOTICED_PLAYER
      set_noticed_movement
    end
    set_sprite_to_current_state
  end

  def check_detect_trainer
    return if $game_system.map_interpreter.running? || @starting
    return pbEventCanReachPlayer?(self, $game_player, @detection_radius)
  end

  def pbCheckEventTriggerAfterTurning
    return if $game_system.map_interpreter.running? || @starting
    if @event.name[/trainer\((\d+)\)/i]
      distance = $~[1].to_i
      if @trigger == 2 && pbEventCanReachPlayer?(self, $game_player, distance)
        start if !jumping? && !over_trigger?
      end
    end
  end


  # The rarer the Pokemon, the more skittish it is (larger sight radius)
  def calculate_ow_pokemon_sight_radius(species_data)
    min_radius = 2
    max_radius = 6
    speed = species_data.base_stats[:SPEED] # Get base Speed stat
    # Scale speed (1–255) to radius
    radius = min_radius + ((speed - 1) / 254.0) * (max_radius - min_radius)
    return radius.round
  end

  def calculate_value_from_stat(species_data, stat, min_value, max_value)
    stat_value = species_data.base_stats[stat]
    average_stat = 70.0
    half_range = (max_value - min_value) / 2.0

    # Center on average stat and scale up/down
    normalized = (stat_value - average_stat) / average_stat
    scaled = (min_value + half_range) + normalized * half_range

    return scaled.clamp(min_value, max_value).round
  end

  #####
  # Noticing player
  # ###

  def getOverworldLandPath
    base_path = "Followers/"
    is_fusion = isSpeciesFusion(@species)
    species_name = @species.to_s
    if @pokemon.shiny?
      base_path += "Shiny/"
    elsif is_fusion
      species_name = species_data.get_body_species_symbol.to_s
      base_path += "Fusions/"
    end
    path = "#{base_path}#{species_name}"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def getOverworldFlyingPath
    base_path = "Followers/"
    is_fusion = isSpeciesFusion(@species)
    species_name = @species.to_s
    if @pokemon.shiny?
      base_path += "Shiny/"
    elsif is_fusion
      species_name = species_data.get_body_species_symbol.to_s
      base_path += "Fusions/"
    end
    path = "#{base_path}#{species_name}_fly"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def getOverworldNoticedPath
    base_path = "Followers/"
    is_fusion = isSpeciesFusion(@species)
    species_name = @species.to_s
    if @pokemon.shiny?
      base_path += "Shiny/"
    elsif is_fusion
      species_name = species_data.get_body_species_symbol.to_s
      base_path += "Fusions/"
    end
    path = "#{base_path}#{species_name}_notice"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def set_sprite_to_current_state
    case @current_state
    when :NOTICED_PLAYER
      set_sprite(@noticed_sprite) if @noticed_sprite
    when :ROAMING
      set_sprite(@roaming_sprite) if @roaming_sprite
    end
  end

  def set_sprite(sprite_path)
    @character_name = sprite_path
    @need_refresh = true
  end

  # Static
  def set_noticed_movement
    if isRepelActive
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 6
    end
    case @behavior_noticed
    when :normal
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    when :curious
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
    when :aggressive
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
      self.move_frequency = 6
    when :shy
      @move_type = MOVE_TYPE_AWAY_PLAYER
    when :skittish
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 6
    when :shy
      @move_type = MOVE_TYPE_AWAY_PLAYER
    when :flee, :flee_flying, :teleport_away
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:noticed][@behavior_noticed])
      @through = true
      @detection_radius =10
    when :flee_flying
      @always_on_top = true
    else
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:noticed][@behavior_noticed])
    end
    @move_speed = @noticed_move_speed
  end

  def set_roaming_movement
    if isRepelActive
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 3
      return
    end

    case @behavior_roaming
    when :random
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    else
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][@behavior_roaming])
    end
    self.move_frequency = 3
    @move_speed = @roaming_move_speed
  end

  def set_custom_move_route(move_list, repeating = true)
    @move_type = MOVE_TYPE_CUSTOM
    @move_route = RPG::MoveRoute.new
    @move_route.repeat = repeating
    @move_route.skippable = true
    @move_route.list = move_list
  end

  def despawn
    $PokemonTemp.overworld_pokemon_on_map.delete(@id)
    erase
  end
end

