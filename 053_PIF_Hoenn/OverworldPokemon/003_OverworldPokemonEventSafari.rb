class SafariOverworldPokemonEvent < DynamicOverworldPokemonEvent
  attr_reader :stole_item
  def setup_pokemon(species, level, terrain, behavior_roaming = nil, behavior_noticed = nil)
    super
    @safari_thief = POKEMON_BEHAVIOR_DATA[@behavior_species][:steal_items]
    echoln "#{species}: #{@safari_thief}"
  end

  def initialize_sprite(terrain, species_data)
    super
    @steal_sprite = getOverworlStealPath(species_data, @pokemon.shiny?)
  end

  def handle_pokemon_near_player
    if should_start_battle? # Battle
          flee() unless (is_eating? || @currently_snatching)
          if @stole_item
            spawn_safari_ball_event
            cancel_appearance_override
            set_sprite_to_current_state
          end
    else
      # check for noticed
      if @current_state == :ROAMING
        if check_detect_trainer
          playDetectAnimation
          @target = :player
          breakDisguise if @disguised
          @noticed_player_once = true
          update_state(:NOTICED_PLAYER)
        end
      end
    end
  end

  def steal_player_item
    @stole_item = true
    return unless pbSafariState.ballcount > 0
    pbSafariState.ballcount -= 1
    updateSafariBallDisplay
  end

  def back_to_roaming_action
    super
  end

  TEMPLATE_EVENT_SAFARI_BALL = 17

  def spawn_safari_ball_event
    x_pos, y_pos = @x, @y
    pbSEPlay("Battle ball shake")
    event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SAFARI_BALL, $game_map.map_id, [x_pos, y_pos], DIRECTION_LEFT)
    event.direction = DIRECTION_UP
  end

  def update
    super
    update_notice_icon
  end

  SNATCH_RUN_STEPS = 5   # 4 + 1 steps away from the player, as in the original
  SNATCH_PAUSE     = 10  # wait before turning back, in 1/20 s units

  def snatch_ball_from_player
    if @stole_item
      cancel_appearance_override
      set_sprite_to_current_state
      flee()
    end
    @currently_snatching = true
    echoln "detection: #{@detection_radius}"
    echoln @direction

    set_roaming_movement
    list = []
    list << move_command(PBMoveRoute::TowardPlayer)
    list << move_command(PBMoveRoute::Script, "perform_snatch")
    SNATCH_RUN_STEPS.times do
      list << move_command(PBMoveRoute::AwayFromPlayer)
    end
    list << move_command(PBMoveRoute::Wait, SNATCH_PAUSE)
    list << move_command(PBMoveRoute::TurnTowardPlayer)
    list << move_command(PBMoveRoute::Script, "finish_snatch")
    list << move_command(PBMoveRoute::End)

    route = RPG::MoveRoute.new
    route.repeat = false
    route.skippable = true
    route.list = list
    force_move_route(route)
  end

  # Runs mid-route, right after the lunge
  def perform_snatch
    playAnimation(HIT_ANIMATION, $game_player.x, $game_player.y)
    steal_player_item
    override_appearance(@steal_sprite) if @steal_sprite
  end

  # Runs at the end of the route
  def finish_snatch
    @behavior_noticed = :skittish
    set_sprite_to_current_state
    @currently_snatching = false
  end

  private

  def move_command(code, *params)
    return RPG::MoveCommand.new(code, params)
  end

  def move_type_curious(next_movement_ready = false)
    if next_movement_ready
      if distance_from_player > 1
        move_toward_player
      else
        if @safari_thief
          snatch_ball_from_player
        else
          roll = rand(6)
          if roll == 0
            turn_random
          elsif roll == 1
            jump(0, 0)
          else
            turn_toward_player
          end
        end
      end
    end
  end

end