def isOutdoor()
  current_map = $game_map.map_id
  map_metadata = GameData::MapMetadata.try_get(current_map)
  return map_metadata && map_metadata.outdoor_map
end


def find_random_walkable_coordinates_near_player(width,height,variance,max_nb_tries = 10)
  found_available_position = false
  current_try = 0
  while !found_available_position
    x, y = getRandomPositionOnPerimeter(width, height, $game_player.x, $game_player.y, variance)
    found_available_position = true if $game_map.passable?(x, y, $game_player.direction)
    current_try += 1
    return nil if current_try > max_nb_tries
  end
  return [x,y]
end


def getRandomPositionOnPerimeter(width, height, center_x, center_y, variance=0,edge=nil)
  half_width = width / 2.0
  half_height = height / 2.0

  # Randomly select one of the four edges of the rectangle
  edge = rand(4) if !edge

  case edge
  when 0 # Top edge
    random_x = center_x + rand(-half_width..half_width)
    random_y = center_y - half_height
  when 1 # Bottom edge
    random_x = center_x + rand(-half_width..half_width)
    random_y = center_y + half_height
  when 2 # Left edge
    random_x = center_x - half_width
    random_y = center_y + rand(-half_height..half_height)
  when 3 # Right edge
    random_x = center_x + half_width
    random_y = center_y + rand(-half_height..half_height)
  end

  return random_x.round, random_y.round
end