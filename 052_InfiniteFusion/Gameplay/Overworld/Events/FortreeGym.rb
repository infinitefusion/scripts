#FORTREE GYM STUFF
#
CARDINALS_CW = [DIRECTION_UP, DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_LEFT]
def rotate_direction(dir, clockwise, steps = 1)
  i = CARDINALS_CW.index(dir)
  CARDINALS_CW[(i + (clockwise ? steps : -steps)) % 4]
end

def clockwise_rotation?(from_dir, to_dir)
  rotate_direction(from_dir, true) == to_dir
end

# Arms of each shape when the event is facing DIRECTION_UP.
GATE_SHAPES = {
  :cross    => [DIRECTION_UP, DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_LEFT],
  :t        => [DIRECTION_LEFT, DIRECTION_UP, DIRECTION_RIGHT],
  :l        => [DIRECTION_LEFT, DIRECTION_UP],
  :straight => [DIRECTION_LEFT, DIRECTION_RIGHT]  #unused
}

# The quadrant an arm sweeps through when it turns clockwise
SWEPT_QUADRANT_CW = {
  DIRECTION_UP    => :top_right,
  DIRECTION_RIGHT => :bottom_right,
  DIRECTION_DOWN  => :bottom_left,
  DIRECTION_LEFT  => :top_left
}

def gate_arms(shape, facing)
  base = GATE_SHAPES[shape]
  return nil if base.nil?
  turns = CARDINALS_CW.index(facing)   # UP = 0 turns, RIGHT = 1, ...
  return nil if turns.nil?
  base.map { |a| rotate_direction(a, true, turns) }
end

def swept_quadrants(arms, clockwise)
  arms.map do |a|
    clockwise ? SWEPT_QUADRANT_CW[a] : SWEPT_QUADRANT_CW[rotate_direction(a, false)]
  end
end

# Returns [lane_side, clockwise]
# lane_side = the side of the 2x2 the player is walking along,
# (also the direction of the arm that would block them)
def windvane_push_info(event)
  dir = $game_player.direction
  case dir
  when DIRECTION_UP, DIRECTION_DOWN
    side = $game_player.x == event.x ? DIRECTION_LEFT : DIRECTION_RIGHT
    clockwise = (dir == DIRECTION_UP) == (side == DIRECTION_LEFT)
  when DIRECTION_LEFT, DIRECTION_RIGHT
    side = $game_player.y == event.y ? DIRECTION_DOWN : DIRECTION_UP  # event.y = bottom row
    clockwise = (dir == DIRECTION_LEFT) == (side == DIRECTION_DOWN)
  else
    return nil
  end
  [side, clockwise]
end

WINDVANE_STEPS = {
  DIRECTION_UP    => [ 0, -1],
  DIRECTION_DOWN  => [ 0,  1],
  DIRECTION_LEFT  => [-1,  0],
  DIRECTION_RIGHT => [ 1,  0]
}

def windvane_exit_clear?(gate_event)
  dir = $game_player.direction
  dx, dy = WINDVANE_STEPS[dir]
  return false if dx.nil?
  x = $game_player.x + dx * 2
  y = $game_player.y + dy * 2
  return false unless $game_map.valid?(x, y)
  $game_map.passable?(x, y, rotate_direction(dir, true, 2), gate_event)
end

# 0 = left/top, 1 = right/bottom (event.y is the bottom row)
# Player's cell in the 2x2: col 0/1 = left/right, row 0/1 = top/bottom.
# event.y is the bottom row.
def windvane_cell(event)
  [$game_player.x - event.x, $game_player.y - (event.y - 1)]
end

def windvane_inside?(event)
  col, row = windvane_cell(event)
  (0..1).include?(col) && (0..1).include?(row)
end

# Only valid when the player is inside the gate.
# Returns [lane_side, clockwise], or nil if the move would leave the gate.
def windvane_push_info(event)
  col, row = windvane_cell(event)
  dir = $game_player.direction
  case dir
  when DIRECTION_UP, DIRECTION_DOWN
    return nil if (dir == DIRECTION_UP && row == 0) || (dir == DIRECTION_DOWN && row == 1)
    side = col == 0 ? DIRECTION_LEFT : DIRECTION_RIGHT
    clockwise = (dir == DIRECTION_UP) == (side == DIRECTION_LEFT)
  when DIRECTION_LEFT, DIRECTION_RIGHT
    return nil if (dir == DIRECTION_LEFT && col == 0) || (dir == DIRECTION_RIGHT && col == 1)
    side = row == 1 ? DIRECTION_DOWN : DIRECTION_UP
    clockwise = (dir == DIRECTION_LEFT) == (side == DIRECTION_DOWN)
  else
    return nil
  end
  [side, clockwise]
end

def windvane_step_clear?
  dir = $game_player.direction
  dx, dy = WINDVANE_STEPS[dir]
  return false if dx.nil?
  x = $game_player.x + dx
  y = $game_player.y + dy
  return false unless $game_map.valid?(x, y)
  # Entering the tile from the side the player comes from
  $game_map.passableStrict?(x, y, rotate_direction(dir, true, 2), $game_player)
end

# Returns true if the player was moved, false if blocked (bumps instead).
def windvane_walk_through(event = nil)
  unless windvane_step_clear?
    windvane_walk_through_blocked
    return false
  end
  pbMoveRoute($game_player, [
    PBMoveRoute::ThroughOn,
    PBMoveRoute::Forward,
    PBMoveRoute::ThroughOff
  ], true)
  true
end


def windvane_walk_through_blocked
  pbMoveRoute($game_player, [
    PBMoveRoute::ThroughOn,
    PBMoveRoute::Forward,
    PBMoveRoute::Backward,
    PBMoveRoute::ThroughOff
  ], true)
end

def windvane_door(event, shape = :cross, blocked_quadrants = [])
  arms = gate_arms(shape, event.direction)
  return if arms.nil?

  # Bumped from outside: no arm is crossed on entry, so just step in.
  # The push happens on the next move, from inside.
  unless windvane_inside?(event)
    windvane_walk_through
    return
  end

  side, clockwise = windvane_push_info(event)
  return if side.nil?

  # No arm where player is walking -> passthrough
  unless arms.include?(side)
    windvane_walk_through(event)
    return
  end

  # Gate is stuck
  unless (swept_quadrants(arms, clockwise) & blocked_quadrants).empty?
    unless windvane_step_clear?
      windvane_walk_through_blocked
      return
    end
    pbSEPlay("creaking")
    windvane_walk_through_blocked
    setFrame(event, clockwise ? 1 : 3)
    pbSEPlay("Player bump")
    pbWait(4)
    resetFrames(event.id)
    pbWait(8)
    return
  end

  pbSEPlay("creaking")
  setFrame(event, clockwise ? 1 : 3)
  windvane_walk_through(event)
  pbWait(4)
  event.direction = rotate_direction(event.direction, clockwise)
  resetFrames(event.id)

  pbSEPlay("wind")
  change_wind_direction(event.direction)
end

#for use in fortree gym
def change_wind_direction(direction)
  var_fortree_wind_direction = 1055
  case direction
  when DIRECTION_DOWN
    pbSet(var_fortree_wind_direction,0)
  when DIRECTION_LEFT
    pbSet(var_fortree_wind_direction,1)
  when DIRECTION_UP
    pbSet(var_fortree_wind_direction,2)
  when DIRECTION_RIGHT
    pbSet(var_fortree_wind_direction,3)
  end
end


def check_path_cloud
  case $game_player.direction
  when DIRECTION_DOWN
    tile_to_check = [$game_player.x, $game_player.y+3]
  when DIRECTION_LEFT
    tile_to_check = [$game_player.x-2, $game_player.y]
  when DIRECTION_UP
    tile_to_check = [$game_player.x, $game_player.y-3]
  when DIRECTION_RIGHT
    tile_to_check = [$game_player.x+2, $game_player.y]
  end

  if $game_map.passable?(tile_to_check[0], tile_to_check[1],$game_player.direction) && $game_map.terrain_tag(tile_to_check[0], tile_to_check[1]).id == :Cloud
    pbMoveRoute($game_player, [
      PBMoveRoute::ThroughOn,
      PBMoveRoute::JumpForward,
      PBMoveRoute::Wait, 4,
      PBMoveRoute::JumpForward,
      PBMoveRoute::Wait, 4,
      PBMoveRoute::JumpForward,
      PBMoveRoute::ThroughOff,
    ], false)
  else
    pbSEPlay("Player bump")
    pbWait(4)
  end

end