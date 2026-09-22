MOVE_TYPE_FIXED = 0
MOVE_TYPE_RANDOM = 1
MOVE_TYPE_TOWARDS_PLAYER = 2
MOVE_TYPE_AWAY_PLAYER = 4

MOVE_TYPE_CURIOUS = 5
MOVE_TYPE_SHY = 6

MOVE_TYPE_TOWARDS_TARGET = 7
MOVE_TYPE_AWAY_FROM_TARGET = 8
MOVE_TYPE_SHY_FROM_TARGET = 9
class OverworldPokemonEvent
  # @stop_count : nb frames since last movement

  #wait until next frequency frame
  def wait
    @stop_count = 0
  end

  def move_type_curious(next_movement_ready = false)
    if next_movement_ready
      if distance_from_player > 1
        move_toward_player
      else
        roll = rand(6)
        if roll == 0
          turn_random
        elsif roll == 1
          jump(0,0)
        else
          turn_toward_player
        end
      end
    end
  end

  def move_type_toward_target(target_event, next_movement_ready = true)
    return unless next_movement_ready
    unless target_event
      move_type_random
      return
    end

    dx = (target_event.x - self.x).abs
    dy = (target_event.y - self.y).abs
    distance = dx + dy

    if distance > 1
      if rand(10) == 0
        move_random
        #turnEventTowardsEvent(self,target_event)
      else
        moveEventTowardsEvent(self, target_event)
      end
      return
    end

    if @noticed_pokemon_behavior == :curious
      roll = rand(10)
      if roll <= 3
        turn_random
      elsif roll <= 6
        turnEventTowardsEvent(self, target_event)
      else
        wait
      end
    else
      turnEventTowardsEvent(self, target_event)
    end
  end

  def move_type_away_from_target(target_event)
    unless target_event
      move_type_random
      return
    end
    moveEventAwayFromEvent(self, target_event)
  end

  def move_type_random
    if @idle_animation_sprite && rand(6)==0
      play_idle_animation
    else
      super
    end
  end

  def play_idle_animation
    return if @playing_idle_animation
    @playing_idle_animation = true
    @old_character_name = @character_name
    @character_name = @idle_animation_sprite
    @stop_count = 0
    step_animation_once
  end

  def update_idle_animation
    if @playing_idle_animation && @step_anime_once_count >= 4
      @character_name = @old_character_name
      @playing_idle_animation = false
    end
  end

  # def move_type_shy(next_movement_ready = false)
  #   if next_movement_ready
  #     move_type_away_from_player
  #     turn_toward_player
  #   end
  # end


  # def move_type_bounce_random(frames_since_last_movement, next_movement_ready = false)
  #   echoln @stop_count
  #   if next_movement_ready
  #     case rand(6)
  #     when 0..3 then
  #       turn_random
  #       jump_forward(1)
  #     when 4 then
  #       jump_forward(1)
  #     when 5 then
  #       wait
  #     end
  #   else
  #     if @stop_count % 15 == 0
  #       jump(0, 0, false)
  #     end
  #   end
  # end
end