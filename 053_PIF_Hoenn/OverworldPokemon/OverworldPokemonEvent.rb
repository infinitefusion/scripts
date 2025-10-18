class OverworldPokemonEvent < Game_Event

  attr_accessor :species
  attr_accessor :eventId
  attr_accessor :level

  attr_accessor :behavior_roaming
  attr_accessor :behavior_noticed

  attr_accessor :flee_delay
  attr_accessor :detection_radius
  attr_accessor :pokemon

  def setup_pokemon(species, level, terrain)
    @species = species
    @level = level
    @pokemon = Pokemon.new(species, level)
    @behavior_species= getBehaviorSpecies

    @behavior_roaming = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_roaming]
    @behavior_noticed = POKEMON_BEHAVIOR_DATA[@behavior_species][:behavior_noticed]

    echoln @behavior_roaming

    @behavior_roaming = :random if !@behavior_roaming
    @behavior_noticed = :normal if !@behavior_noticed

    @can_flee = POKEMON_BEHAVIOR_DATA[@behavior_species][:can_flee] || false

    @flee_delay = calculate_ow_pokemon_flee_delay
    @detection_radius = calculate_ow_pokemon_sight_radius

    @current_state = :ROAMING # Possible values: :ROAMING, :NOTICED_PLAYER, :FLEEING

    @deleted = false


    @event.name = "OW/#{species.to_s}/#{level.to_s}"

    initialize_sprite(terrain)
    @is_flying = @character_name == @flying_sprite
    @step_anime=@is_flying
    @always_on_top = @is_flying
    if terrain == :Water
      unless @is_flying
        self.forced_bush_depth = 20
        self.calculate_bush_depth
      end
    end

    if @pokemon.shiny?
      pbSEPlay("shiny", 60)
      playAnimation(Settings::SPARKLE_SHORT_ANIMATION_ID,@x, @y)
    end
    set_roaming_movement
  end

  def getBehaviorSpecies
    if isSpeciesFusion(@species)
      return GameData::FusedSpecies.get(species).get_head_species_symbol
    end
    return @species
  end

  def initialize_sprite(terrain)
    @land_sprite = getOverworldLandPath
    @flying_sprite = getOverworldFlyingPath
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
    self.erase
    $PokemonTemp.overworld_pokemon_on_map.delete(@eventId)
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
    if @behavior_noticed == :shy || @behavior_noticed == :skittish || @behavior_noticed == :still || @can_flee
      playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    elsif @behavior_noticed == :curious
      playAnimation(Settings::QUESTION_MARK_ANIMATION_ID, @x, @y)
    elsif @behavior_noticed == :aggressive
      playAnimation(Settings::ANGRY_ANIMATION_ID, @x, @y)
    end
  end

  def update_behavior()
    return if @opacity == 0
    if player_near_event?(@detection_radius)
      # --- Check flee first ---
      if $game_player.moving?
        should_flee = should_flee?
        should_flee = true if pbFacingEachOther(self, $game_player)
        if should_flee
          ow_pokemon_flee
          pbWait(8)
          return
        end
      end

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
      update_state(:ROAMING) if @current_state != :ROAMING
    end
  end

  def turn_generic(*args)
    super(*args)

  end

  def update_state(new_state)
    @current_state = new_state
    update_movement_type
  end

  def update_movement_type
    case @current_state
    when :ROAMING
      set_roaming_movement
    when :NOTICED_PLAYER
      set_noticed_movement
    end
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

  # fleeDelay: The time (in seconds) you need to wait between steps for the Pokemon not to flee
  # FIXME: broken
  def should_flee?()
    return false unless @can_flee
    $PokemonTemp.overworld_pokemon_flee ||= {}
    key = "#{$game_map.map_id}_#{@eventId}"
    current_time = Time.now.to_f
    last_time = $PokemonTemp.overworld_pokemon_flee[key]
    if last_time
      time_past = current_time - last_time
      echoln "last time: #{last_time}, current time: #{current_time}, time past: #{time_past}"

      if time_past < @flee_delay
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

  # Fleeing
  def ow_pokemon_flee(silent = false)
    flee_sprite = get_overworld_pokemon_flee_sprite(@species)
    @character_name = flee_sprite if flee_sprite
    playCry(species) if species && !silent
    pbSEPlay(SE_FLEE) unless silent
    @move_speed = 4
    @move_away_from_player
    @opacity -= 50
    @move_away_from_player
    @opacity -= 50
    @move_away_from_player
    @opacity -= 50
    erase
  end

  def get_overworld_pokemon_flee_sprite(species)
    flee_sprite = "Graphics/Characters/Followers/#{species.to_s}_flee"
    if pbResolveBitmap(flee_sprite)
      return "Followers/#{species}_flee"
    end
    return nil
  end

  # The harder the pokemon is to catch, the more skittish it is (shorter flee delay)
  def calculate_ow_pokemon_flee_delay
    min_delay = 1
    max_delay = 4
    catch_rate = GameData::Species.get(@species).catch_rate
    delay = max_delay - ((catch_rate - 1) / 254.0) * (max_delay - min_delay)
    return delay.round
  end

  # The rarer the Pokemon, the more skittish it is (larger sight radius)
  def calculate_ow_pokemon_sight_radius()
    min_radius = 2
    max_radius = 6
    catch_rate = GameData::Species.get(@species).catch_rate
    radius = min_radius + ((255 - catch_rate) / 254.0) * (max_radius - min_radius)
    return radius.round
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
      species_name = GameData::FusedSpecies.get(@species).get_body_species_symbol.to_s
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
      species_name = GameData::FusedSpecies.get(@species).get_body_species_symbol.to_s
      base_path += "Fusions/"
    end
    path = "#{base_path}#{species_name}_fly"
    if pbResolveBitmap("Graphics/Characters/#{path}")
      return path
    end
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
    end
  end

  def set_roaming_movement
    # @move_type = MOVE_TYPE_CUSTOM
    #
    # @move_route = RPG::MoveRoute.new
    # @move_route.repeat = true
    # @move_route.skippable = true
    # @move_route.list = OW_BEHAVIOR_MOVE_ROUTES[:roaming][:burrow][:move_route]
    # return


    if isRepelActive
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 3
      return
    end

    echoln @behavior_roaming
    case @behavior_roaming
    when :random,
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    when :still_teleport
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][:still_teleport])
    when :random_burrow
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][:random_burrow])
    when :random_vanish
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][:random_vanish])
    end
    self.move_frequency = 3
  end

  def set_custom_move_route(move_list)
    echoln "set_custom_move_route"
    @move_type = MOVE_TYPE_CUSTOM
    @move_route = RPG::MoveRoute.new
    @move_route.repeat = true
    @move_route.skippable = true
    @move_route.list = move_list
  end

end

