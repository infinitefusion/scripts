class OverworldPokemonEvent < Game_Event
  alias setup_pokemon_detection setup_pokemon
  def setup_pokemon(*args)
    setup_pokemon_detection(*args)
    @currently_seen_events = []
    @previously_seen_events = []
  end

  alias turn_generic_pokeonn_detection turn_generic
  def turn_generic(*args)
    turn_generic_pokeonn_detection(*args)
    @currently_seen_events = listEventsInVisionCone
    echoln @currently_seen_events
  end

  #-----------------------------------------------------------------------
  # Returns the forward distance (along the facing axis) to (px, py) if it
  # falls inside the vision cone, or nil if it doesn't. Returning the
  # distance instead of a bool lets callers build a hash without
  # recomputing dy/dx a second time.
  #-----------------------------------------------------------------------
  def pbConeDistanceTo(px, py, distance, spread = 1)
    return nil if distance <= 0
    ex = self.x
    ey = self.y
    case self.direction
    when 2 # Facing Down
      dy = py - ey
      return nil if dy <= 0 || dy > distance
      side = (px - ex).abs
      return (side <= dy * spread) ? dy : nil
    when 8 # Facing Up
      dy = ey - py
      return nil if dy <= 0 || dy > distance
      side = (px - ex).abs
      return (side <= dy * spread) ? dy : nil
    when 6 # Facing Right
      dx = px - ex
      return nil if dx <= 0 || dx > distance
      side = (py - ey).abs
      return (side <= dx * spread) ? dx : nil
    when 4 # Facing Left
      dx = ex - px
      return nil if dx <= 0 || dx > distance
      side = (py - ey).abs
      return (side <= dx * spread) ? dx : nil
    else
      return nil
    end
  end

  # Boolean wrapper, kept so existing call sites don't need to change.
  def pbPointInVisionCone?(px, py, distance, spread = 1)
    !pbConeDistanceTo(px, py, distance, spread).nil?
  end

  def pbPlayerInEventCone?(player, distance, spread = 1)
    return false if !player
    pbPointInVisionCone?(player.x, player.y, distance, spread)
  end

  #-----------------------------------------------------------------------
  # { event => distance }
  #-----------------------------------------------------------------------
  def listEventsInVisionCone(distance = @detection_radius, spread = 1)
    seen = {}
    return seen if !$game_map

    #TODO: Maybe. Use this for player also and refactor player detection in base OverworldEvent
    # If not too costly to run this every frame like we do for the player detection...
    #
    # player_distance = pbConeDistanceTo($game_player.x, $game_player.y, distance, spread)
    # seen[$game_player] = player_distance if player_distance

    $game_map.events.each_value do |event|
      next unless event.is_a?(OverworldPokemonEvent)
      next if event == self
      next if event.erased
      d = pbConeDistanceTo(event.x, event.y, distance, spread)
      seen[event] = d if d
    end

    return seen
  end

  def check_detect_trainer
    return unless noticed_state_different_from_roaming()
    return if $game_system.map_interpreter.running? || @starting
    return pbPlayerInEventCone?($game_player, @detection_radius)
  end
end