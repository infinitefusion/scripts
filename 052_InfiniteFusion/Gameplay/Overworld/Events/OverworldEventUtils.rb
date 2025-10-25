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


DIRECTION_ALL  = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL  = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL  = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL  = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL  = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

def kick_ball(eventId)
  ball = $game_map.events[eventId]
  return if !ball

  dir = $game_player.direction
  dx = (dir == DIRECTION_RIGHT ? 1 : dir == DIRECTION_LEFT ? -1 : 0)
  dy = (dir == DIRECTION_DOWN ? 1 : dir == DIRECTION_UP ? -1 : 0)

  # Shorter kick distance — scales gently with speed
  player_speed = $game_player.move_speed
  remaining_distance = [player_speed * 0.8, 1].max.floor

  pbSEPlay("jump", 80, 100) rescue nil
  pbWait(3)

  current_dir = dir
  total_bounces = 0
  max_bounces = 3

  while remaining_distance > 0 && total_bounces < max_bounces
    travel = 0
    while travel < remaining_distance
      test_x = ball.x + dx * (travel + 1)
      test_y = ball.y + dy * (travel + 1)
      break if !$game_map.passable?(test_x - dx, test_y - dy, current_dir) ||
        !$game_map.passable?(test_x, test_y, current_dir)
      travel += 1
    end

    if travel > 0
      ball.jump(dx * travel, dy * travel)
      pbWait(6)
    end

    if travel < remaining_distance
      pbSEPlay("jump", 80, 80) rescue nil
      total_bounces += 1
      remaining_distance = [remaining_distance / 2.0, 1].max.floor

      pbWait(6)

      dx *= -1
      dy *= -1
      current_dir = case current_dir
                    when DIRECTION_UP then DIRECTION_DOWN
                    when DIRECTION_DOWN then DIRECTION_UP
                    when DIRECTION_LEFT then DIRECTION_RIGHT
                    when DIRECTION_RIGHT then DIRECTION_LEFT
                    end

      bounce_dist = [remaining_distance / 2.0, 1].max.floor
      ball.jump(dx * bounce_dist, dy * bounce_dist)
      pbWait(8)
    else
      remaining_distance = 0
    end
  end
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
      pbWait(8)
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

def getOnBoat
  set_player_graphics("boat_briney")
  $PokemonTemp.prevent_ow_battles=true
  $PokemonGlobal.boat=true
end

def getOffBoat
  reset_player_graphics
  $PokemonTemp.prevent_ow_battles=false
  $PokemonGlobal.boat=false
end

def check_beach_seashell
  pbMessage("\PN flipped the seashell over...")
  pearl_chance = 2
  pokemon_chance = 20
  roll = rand(1..100)
  if roll <= pearl_chance
    pbReceiveItem(:PEARL)
  elsif roll <= pearl_chance + pokemon_chance
    possible_pokemon = [:KRABBY] #if added to the game, also dwebble, binacle?
    event = $game_map.events[@event_id]
    # Spawn Pokémon
    level = rand(8..16)
    pbWait(4)
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID,$game_player.x,$game_player.y)
    spawn_random_overworld_pokemon_group([possible_pokemon.sample, level], 1, 3, [event.x, event.y], :Cave)
  else
    # Nothing
    pbMessage(_INTL("...There's nothing there."))
  end
end

def clefairy_minigame(length=4)
  possible_elements = ["Left!"," Up!","Right!","Down!"]
  pbMessage("Listen up and remember this!")
  sequence = []
  message = ""
  (0...length).each { |i|
    element = possible_elements.sample
    sequence << element
    message += element
    message += "\\wt[20]"
    message +=" "
  }
  message += "\\wtnp[40]"
  pbWait(8)
  pbMessage(message)
  pbMessage("Get ready... Press the buttons!\\wtnp[20]")

  player_input = []
  loop do
    if Input.trigger?(Input::LEFT)
      player_input << possible_elements[0]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::UP)
      player_input << possible_elements[1]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::RIGHT)
      player_input << possible_elements[2]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::DOWN)
      player_input << possible_elements[3]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::BACK)
      pbSEPlay("GUI sel buzzer", 80, 100)
      return false
    end
    Graphics.update
    Input.update
    break if player_input.size == sequence.size
  end

  pbWait(10)
  if player_input == sequence
    pbSEPlay("GUI naming confirm", 80, 100)
    pbMessage("Correct!")
    return true
  else
    pbSEPlay("GUI sel buzzer", 80, 100)
    pbMessage("Incorrect!")
    return false
  end
end
