class OverworldPokemonEvent < Game_Event

  attr_accessor :species
  attr_accessor :level

  attr_accessor :behavior_roaming
  attr_accessor :behavior_noticed

  attr_accessor :detection_radius
  attr_accessor :pokemon
  attr_accessor :manual_ow_pokemon

  DISTANCE_FOR_DESPAWN = 16
  FLEEING_BEHAVIORS = [:flee, :flee_flying, :teleport_away]

  def setup_pokemon(species, level, terrain, behavior_roaming = nil, behavior_noticed = nil)
    @species = species
    @level = level
    @behavior_roaming = behavior_roaming if behavior_roaming
    @behavior_noticed = behavior_noticed if behavior_noticed
    @terrain = terrain
    species_data = GameData::Species.get(@species)

    @pokemon = Pokemon.new(species, level)
    @behavior_species = getBehaviorSpecies(species_data)

    unless behavior_roaming
      @behavior_roaming = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_roaming]
      @behavior_roaming = :random unless @behavior_roaming
    end
    unless behavior_noticed
      @behavior_noticed = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_noticed]
      @behavior_noticed = nil unless @behavior_noticed
    end

    default_move_speed = calculate_value_from_stat(species_data, :SPEED, 1, 4)
    @roaming_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_move_speed] || default_move_speed
    @noticed_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_move_speed] || default_move_speed

    default_frequency = calculate_value_from_stat(species_data, :ATTACK, 1, 5)
    @roaming_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_frequency] || default_frequency
    @noticed_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_frequency] || default_frequency

    @detection_radius = calculate_ow_pokemon_sight_radius(species_data)

    #When the player is next to a Pokemon but not facing it, there is a delay before it battles.
    # The battle will start when the timer reaches @nearby_notice_limit
    # @nearby_notice_limit depends on the size of the pokemon. (usually around 3-5 ticks)
    @nearby_notice_timer = 0
    @nearby_notice_limit = 4#calculate_value_from_ref_value(species_data.weight.to_f/10,2,12, 8)# weight is multiplied by 10 in the pokemon data for some reason
    @current_state = :ROAMING # Possible values: :ROAMING, :NOTICED_PLAYER, :FLEEING

    @deleted = false
    @manual_ow_pokemon = false
    #@event.name = "OW/#{species.to_s}/#{level.to_s}"

    initialize_sprite(@terrain, species_data)
    @roaming_sprite = @character_name
    @is_flying = @character_name == @flying_sprite
    @step_anime = @is_flying
    @forced_z = 300 if @is_flying     #@always_on_top = @is_flying
    if @terrain == :Water
      set_swimming
    end

    if @pokemon.shiny?
      pbSEPlay("shiny", 60)
      playAnimation(Settings::SPARKLE_SHORT_ANIMATION_ID, @x, @y)
    end
    set_roaming_movement
  end

  def set_swimming
    return if @species == :SURSKIT
    unless @is_flying
      self.forced_bush_depth = 20
      self.calculate_bush_depth
    end
  end

  def set_shiny
    @pokemon.shiny = true
    @pokemon.natural_shiny = true
    species_data = GameData::Species.get(@species)
    initialize_sprite(@terrain, species_data)
  end

  #Used for special static pokemon - if need other actions after the pokemon was battled

  def set_post_battle_switch(switch_nb)
    @post_battle_switch = switch_nb if switch_nb.is_a?(Integer)
  end

  def getBehaviorSpecies(species_data)
    if isSpeciesFusion(@species)
      return species_data.get_head_species_symbol
    end
    return @species
  end

  def initialize_sprite(terrain, species_data)
    @land_sprite = getOverworldLandPath(species_data)
    @flying_sprite = getOverworldFlyingPath(species_data)
    @noticed_sprite = getOverworldNoticedPath(species_data)

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
    return if lock?
    return if $PokemonTemp.prevent_ow_battles
    return if instance_variable_get(:@_triggered)
    instance_variable_set(:@_triggered, true)
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    turn_toward_player
    playCry(@species)
    @pokemon.ow_coordinates = [@x, @y]
    $PokemonTemp.overworld_wild_battle_participants = [] if !$PokemonTemp.overworld_wild_battle_participants
    $PokemonTemp.overworld_wild_battle_participants << @pokemon
    pbWait(4)
    trigger_overworld_wild_battle
    echoln @post_battle_switch
    if @post_battle_switch && @post_battle_switch.is_a?(Integer) && @post_battle_switch >=1
      $game_switches[@post_battle_switch] = true
    end
    despawn
    return
  end

  def flee(behavior)
    return if @pokemon.shiny?
    playCry(@species)
    pbSEPlay(SE_FLEE)
    if FLEEING_BEHAVIORS.include?(@behavior_noticed)
      flee_behavior = OW_BEHAVIOR_MOVE_ROUTES[:noticed][@behavior_noticed]
    else
      flee_behavior = OW_BEHAVIOR_MOVE_ROUTES[:noticed][:flee]
    end
    set_custom_move_route(flee_behavior, false)
    @through = true
    @detection_radius = 10
    force_move_route(@move_route)
    @always_on_top = true if behavior == :flee_flying
    @current_state = :FLEEING
  end

  #####
  # Behaviors
  #####
  def noticed_state_different_from_roaming
    return false unless @behavior_noticed
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
    elsif @behavior_noticed == :semi_aggressive
      playAnimation(Settings::ANGRY_SHORT_ANIMATION_ID, @x, @y)
    else
      playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    end
  end

  def update_behavior()
    return if @opacity == 0
    return if @current_state == :FLEEING
    distance = distance_from_player()
    is_near_player = distance <= @detection_radius
    if distance >= DISTANCE_FOR_DESPAWN
      despawn unless @manual_ow_pokemon
    end
    if is_near_player
      if should_start_battle? # Battle
        if isRepelActive && pokemon_can_be_repelled
          playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
          flee(@behavior_noticed)
        else
          overworldPokemonBattle
        end
      else
        # check for noticed
        if @current_state == :ROAMING
          if check_detect_trainer
            playDetectPlayerAnimation
            update_state(:NOTICED_PLAYER)
          end
        end
      end
    else
      if @current_state != :ROAMING
        update_state(:ROAMING)
        back_to_roaming_action
      end
    end
  end

  #Automatically starts a battle if the player is 1 tile away from the Pokemon.
  # If the player is behind or to the side of the pokemon, there is a slight delay
  def should_start_battle?
    should_start = false
    if player_near_event?(1)
      return true if $PokemonTemp.overworld_wild_battle_participants.length >= 1 #Notice immediately if a pokemon is already attacking so that double battles are more likely
      position = playerPositionRelativeToEvent
      if position[:front]
        should_start = true
      elsif position[:back]
        @nearby_notice_timer += 1
        @nearby_notice_timer += 1 if @current_state == :NOTICED_PLAYER
      elsif position[:side]
        @nearby_notice_timer += 2
        should_start = true if @current_state == :NOTICED_PLAYER
      end
      if @nearby_notice_timer > @nearby_notice_limit
        should_start = true
      end
    else
      @nearby_notice_timer =0
    end
    @nearby_notice_timer if should_start
    return should_start
  end
  def pokemon_can_be_repelled
    return $Trainer.party[0].level > @pokemon.level && !@pokemon.shiny?
  end

  def turn_generic(*args)
    super(*args)
  end

  # called when a pokemon that has noticed the player goes back to roaming
  def back_to_roaming_action
    case @behavior_noticed
    when :skittish, :shy
      turn_toward_player
    end
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
    return unless noticed_state_different_from_roaming()
    return if $game_system.map_interpreter.running? || @starting
    # return pbEventCanReachPlayer?(self, $game_player, @detection_radius)
    return pbPlayerInEventCone?(self, $game_player, @detection_radius)
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

  #Generic version of calculate_value_from_stat. You provide the value.
  # There's an optional curve_factor if it shouldn't be linear
  # > 1 : steeper towards the end
  # < 1 steeper towards the beginning
  def calculate_value_from_ref_value(ref_value, min_value, max_value, curve_factor = 1)
    ref_value = [ref_value, 1].max

    # Logarithmic scaling 0 → 1
    scaled_value = Math.log(ref_value) / curve_factor
    normalized = scaled_value / (1 + scaled_value)

    # Scale to range
    value = min_value + normalized * (max_value - min_value)
    value.round
  end

  #####
  # Noticing player
  # ###12

  def get_base_sprite_path(is_fusion, species_name)
    base_path = "Followers/"
    if is_fusion
      base_path += "Fusions/"
    end
    if @pokemon.shiny?
      base_path += "Shiny/"
    end
    return base_path
  end

  def getOverworldLandPath(species_data)
    is_fusion = isSpeciesFusion(@species)
    if is_fusion
      species_name = species_data.get_body_species_symbol.to_s
    else
      species_name = @species.to_s
    end
    base_path = get_base_sprite_path(is_fusion, species_name)
    path = "#{base_path}#{species_name}"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def getOverworldFlyingPath(species_data)
    is_fusion = isSpeciesFusion(@species)
    if is_fusion
      species_name = species_data.get_body_species_symbol.to_s
    else
      species_name = @species.to_s
    end
    base_path = get_base_sprite_path(is_fusion, species_name)
    path = "#{base_path}#{species_name}_fly"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def getOverworldNoticedPath(species_data)
    is_fusion = isSpeciesFusion(@species)
    if is_fusion
      species_name = species_data.get_body_species_symbol.to_s
    else
      species_name = @species.to_s
    end
    base_path = get_base_sprite_path(is_fusion, species_name)
    path = "#{base_path}#{species_name}_notice"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
  end

  def set_sprite_to_current_state
    case @current_state
    when :NOTICED_PLAYER, :FLEEING
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
      return
    end
    return unless @behavior_noticed
    case @behavior_noticed
    when :random
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    when :curious # slowly walk towards player until close, then look at them
      @move_type = MOVE_TYPE_CURIOUS
    when :semi_aggressive # slowly walks towards player until battle
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
    when :aggressive
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
      self.move_frequency = 6
    when :skittish
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 6
    when :flee, :flee_flying, :teleport_away
      flee(@behavior_noticed)
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

  # Additional move types for OW pokemon
  def update_command_new
    super
    ready_for_next_movement = @stop_count >= self.move_frequency_real
    case @move_type
    when MOVE_TYPE_CURIOUS
      move_type_curious(ready_for_next_movement)
    end
  end
end

