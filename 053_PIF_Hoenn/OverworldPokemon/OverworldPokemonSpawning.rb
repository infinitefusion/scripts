# Todo: Templates that depend on the type of Pokemon

# Skittish (can run away, large detection radius)
# Normal (just hangs out)
# Aggressive (goes towards player when in detection radius)
# still (cocoons, etc.) - doesn't move at all
#
# Flying: Wingull, Taillow, Hoppip, etc. when over water
#

# A special type of event that is a Pokemon visible in the overworld. It flees if the player gets too close.
# Can either spawn naturally or be static

OVERWORLD_POKEMON_COMMENT_TRIGGER = "OverworldPokemon"

def should_spawn_overworld_pokemon?
  return false unless $PokemonSystem.overworld_encounters
  return false if $PokemonTemp.prevent_ow_encounters
  return false unless $PokemonGlobal.stepcount % 25 == 0
  return rand(100) > 25 # true
end

def playOverworldPokemonSpawnAnimation(event, terrain)
  case terrain
  when :Land
    playAnimation(Settings::GRASS_ANIMATION_ID, event.x, event.y)
  when :Cave
    playAnimation(Settings::DUST_ANIMATION_ID, event.x, event.y)
  when :Water
    playAnimation(PUDDLE_ANIMATION_ID, event.x, event.y)
  end
end

def get_ow_pokemon_roaming_behavior_template(pokemon)
  species  =  pokemon[0]
  if isSpeciesFusion(species)
    species = GameData::FusedSpecies.get(species).get_head_species_symbol.to_s
  end
  behavior = POKEMON_BEHAVIOR_DATA[species][:behavior_roaming]
  case behavior
  when :normal, :shy, :curious, :aggressive
    return TEMPLATE_EVENT_OW_POKEMON_NORMAL
  when :skittish, :still
    return TEMPLATE_EVENT_OW_POKEMON_STILL
  else
    return TEMPLATE_EVENT_OW_POKEMON_NORMAL
  end
end

def create_overworld_pokemon_event(pokemon, position, terrain)
  template_event = get_ow_pokemon_roaming_behavior_template(pokemon)
  event = $PokemonTemp.createTempEvent(template_event, $game_map.map_id, position)
  return unless event.detectCommentCommand(OVERWORLD_POKEMON_COMMENT_TRIGGER)

  species = pokemon[0]
  level = pokemon[1]
  event.character_name = getOverworldSpritePath(species)
  event.event.name = "OW/#{species.to_s}/#{level.to_s}"
  if terrain == :Water
    event.forced_bush_depth = 20
    event.calculate_bush_depth
  end
  playOverworldPokemonSpawnAnimation(event, terrain)
  return event
end

def getOverworldSpritePath(species)
  if isSpeciesFusion(species)
    species_name = GameData::FusedSpecies.get(species).get_body_species_symbol.to_s
    return "Followers/Fusions/#{species_name.to_s}_fusion"

  else
    return "Followers/#{species.to_s}"
  end
end

def get_overworld_pokemon_group_size(species, max_group_size)
  catch_rate = GameData::Species.get(species).catch_rate
  t = (catch_rate - 1) / 254.0
  t = 1 - Math.sqrt(t) # invert to favor smaller groups

  # Base group size, biased toward smaller numbers
  base = 1 + (t * (max_group_size - 1) * 0.5) # multiply by 0.5 to shrink toward 1–2

  # Random variation: mostly negative or zero, rarely positive
  variation = if rand < 0.6
                -1
              elsif rand < 0.9
                0
              else
                1
              end

  size = (base.round + variation).clamp(1, max_group_size)
  return size
end

def spawn_random_overworld_pokemon_group(wild_pokemon = nil, radius = 10, max_group_size = 4)
  return unless $PokemonEncounters && $PokemonGlobal

  if $PokemonTemp.overworld_pokemon_on_map.length >= Settings::OVERWORLD_POKEMON_LIMIT
    despawn_overworld_pokemon($PokemonTemp.overworld_pokemon_on_map[0])
  end

  if $PokemonGlobal.surfing && $PokemonEncounters.has_water_encounters?
    terrain = :Water
    position = find_random_surfable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  elsif $PokemonEncounters.has_cave_encounters?
    terrain = :Cave
    position = find_random_walkable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  elsif $PokemonEncounters.has_land_encounters?
    terrain = :Land
    position = find_random_tall_grass_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  end
  encounter_type = getTimeBasedEncounter(terrain)

  return unless encounter_type && position
  wild_pokemon = getRegularEncounter(encounter_type) if !wild_pokemon
  return unless wild_pokemon
  species = wild_pokemon[0]
  number_to_spawn = get_overworld_pokemon_group_size(species, max_group_size)
  echoln "Spawning a group of #{number_to_spawn} #{species}"
  for i in 0...number_to_spawn
    next if $PokemonTemp.overworld_pokemon_on_map.length >= Settings::OVERWORLD_POKEMON_LIMIT
    offset_x = rand(-2..2)
    offset_y = rand(-2..2)
    new_position = [position[0] + offset_x, position[1] + offset_y]
    begin
      if $game_map.playerPassable?(new_position[0], new_position[1], DIRECTION_ALL)
        event = create_overworld_pokemon_event(wild_pokemon, new_position, terrain)
        $PokemonTemp.overworld_pokemon_on_map << event.id
      end
    rescue
      next
    end
  end
end

def despawn_overworld_pokemon(event_id)
  event = $game_map.events[event_id]
  return unless event
  overworldPokemonFlee(event, nil, true)
end

class PokemonTemp
  attr_accessor :overworld_wild_battle_participants
  attr_accessor :overworld_wild_battle_triggered

  attr_accessor :overworld_pokemon_on_map
  attr_accessor :prevent_ow_encounters
end

Events.onStepTaken += proc { |sender, e|
  next unless $scene.is_a?(Scene_Map)
  next unless Settings::GAME_ID == :IF_HOENN
  next if isRepelActive()
  if should_spawn_overworld_pokemon?
    spawn_random_overworld_pokemon_group
  end
}

Events.onMapChange += proc { |_sender, e|
  next unless Settings::HOENN
  clearOverworldPokemon
}

def clearOverworldPokemon
  $PokemonTemp.pbClearTempEvents
  $PokemonTemp.overworld_pokemon_on_map = []
  $PokemonTemp.overworld_wild_battle_triggered = false
  $PokemonTemp.overworld_wild_battle_participants = []
end

