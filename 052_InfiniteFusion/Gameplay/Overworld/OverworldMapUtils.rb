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
    found_available_position = true if $game_map.playerPassable?(x, y, $game_player.direction)
    current_try += 1
    return nil if current_try > max_nb_tries
  end
  return [x,y]
end

def find_random_tall_grass_coordinates_near_player(width,height,variance,max_nb_tries = 10)
  found_available_position = false
  current_try = 0
  while !found_available_position
    x, y = getRandomPositionOnPerimeter(width, height, $game_player.x, $game_player.y, variance)

    terrain = $game_map.terrain_tag(x, y)
    found_available_position = terrain.land_wild_encounters
    current_try += 1
    return nil if current_try > max_nb_tries
  end

  encounter_type = :Land  #default grass
  encounter_type = :Land1 if terrain.id == :Grass_alt1
  encounter_type = :Land2 if terrain.id == :Grass_alt2
  encounter_type = :Land3 if terrain.id == :Grass_alt3
  encounter_type = :TallGrass if terrain.id == :TallGrass

  return [x,y],encounter_type
end


def find_random_surfable_coordinates_near_player(width,height,variance,max_nb_tries = 10)
  found_available_position = false
  current_try = 0
  while !found_available_position
    x, y = getRandomPositionOnPerimeter(width, height, $game_player.x, $game_player.y, variance)

    terrain = $game_map.terrain_tag(x, y)
    found_available_position = terrain.can_surf
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


def setVariableToLeaderType(variable=5)
  if $game_switches[SWITCH_RANDOM_TRAINERS]
    gymArray = pbGet(VAR_GYM_TYPES_ARRAY)
  else
    gymArray = GYM_TYPES_ARRAY
  end
  currentGym = pbGet(VAR_CURRENT_GYM_TYPE)
  typeIndex = gymArray[currentGym]
  type = PBTypes.getName(typeIndex)
  $game_variables[variable] = type
end

def increaseDarknessRadius(increase_by)
  return unless $PokemonTemp.darknessSprite
  $PokemonTemp.darknessSprite.radius += increase_by
end

def setDarknessRadius(value)
  return unless $PokemonTemp.darknessSprite
  echoln "setting to #{value}"
  $PokemonTemp.darknessSprite.radius = value
end

