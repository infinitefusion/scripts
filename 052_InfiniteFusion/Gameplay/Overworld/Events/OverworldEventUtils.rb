def turnEventTowardsEvent(turning, turnedTowards)
  event_x = turnedTowards.x
  event_y = turnedTowards.y
  if turning.x < event_x
    turning.turn_right # Event is to the right of the player
  elsif turning.x > event_x
    turning.turn_left # Event is to the left of the player
  elsif turning.y < event_y
    turning.turn_down # Event is below the player
  elsif turning.y > event_y
    turning.turn_up # Event is above the player
  end
end

def turnPlayerTowardsEvent(event)
  if event.is_a?(Integer)
    event = $game_map.events[event]
  end

  event_x = event.x
  event_y = event.y
  if $game_player.x < event_x
    $game_player.turn_right # Event is to the right of the player
  elsif $game_player.x > event_x
    $game_player.turn_left # Event is to the left of the player
  elsif $game_player.y < event_y
    $game_player.turn_down # Event is below the player
  elsif $game_player.y > event_y
    $game_player.turn_up # Event is above the player
  end
end

def giveJigglypuffScribbles(possible_versions = [1, 2, 3, 4])
  selected_scribbles_version = possible_versions.sample
  case selected_scribbles_version
  when 1
    scribbles_id = HAT_SCRIBBLES1
  when 2
    scribbles_id = HAT_SCRIBBLES2
  when 3
    scribbles_id = HAT_SCRIBBLES3
  when 4
    scribbles_id = HAT_SCRIBBLES4
  end
  return if !scribbles_id

  if !hasHat?(scribbles_id)
    $Trainer.unlocked_hats << scribbles_id
  end
  putOnHat(scribbles_id, true, true)
end

# type:
# 0: default
# 1: wood
def sign(message, type = 0)
  signId = "sign_#{type}"
  formatted_message = "\\sign[#{signId}]#{message}"
  pbMessage(formatted_message)
end

def setEventGraphicsToPokemon(species, eventId)
  event = $game_map.events[eventId]
  return if !event
  event.character_name = "Followers/#{species.to_s}"
  event.refresh
end

# time in seconds
def idleHatEvent(hatId, time, switchToActivate = nil)
  map = $game_map.map_id
  i = 0
  while i < (time / 5) do
    # /5 because we update 5 times per second
    return if $game_map.map_id != map
    i += 1
    pbWait(4)
    i = 0 if $game_player.moving?
    echoln i
  end
  $game_switches[switchToActivate] = true if switchToActivate
  obtainHat(hatId)
end

def sit_on_chair()
  pbSEPlay("jump", 80, 100)
  $game_player.through =true
  $game_player.jump_forward
  $game_player.turn_180
  $game_player.through =false
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap

    direction = checkInputDirection
    if direction
      facing_terrain = $game_player.pbFacingTerrainTag(direction)
      if facing_terrain.chair
        pbSEPlay("jump", 80, 100)
        $game_player.direction_fix=true
        $game_player.jumpTowards(direction)
        $game_player.direction_fix=false
      else
        passable_from_direction = $game_map.passable?($game_player.x,$game_player.y,direction)
        if passable_from_direction
          $game_player.turn_generic(direction)
          $game_player.jump_forward
          break
        else
          $game_player.turn_generic(direction)
          $game_player.turn_180
        end
      end
    end
  end
end

def checkInputDirection
  return DIRECTION_UP if Input.trigger?(Input::UP)
  return DIRECTION_DOWN if Input.trigger?(Input::DOWN)
  return DIRECTION_LEFT if Input.trigger?(Input::LEFT)
  return DIRECTION_RIGHT if Input.trigger?(Input::RIGHT)
  return nil
end