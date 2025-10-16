# A special type of event that is a Pokemon visible in the overworld. It flees if the player gets too close.
# Can either spawn naturally or be static

OVERWORLD_POKEMON_COMMENT_TRIGGER = "OverworldPokemon"

def should_spawn_overworld_pokemon?
  return true
end

def create_overworld_pokemon_event(pokemon,position)
  event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_OW_POKEMON, $game_map.map_id, position)
  return unless event.detectCommentCommand(OVERWORLD_POKEMON_COMMENT_TRIGGER)

  species = pokemon[0]
  level = pokemon[1]
  event.character_name = "Followers/#{species}"
  event.event.name = "OW_#{species.to_s}_#{level.to_s}"
end

def spawn_random_overworld_pokemon
  return unless $PokemonEncounters && $PokemonGlobal
  if $PokemonGlobal.surfing && $PokemonEncounters.has_water_encounters?
    encounter_type =   getTimeBasedEncounter(:Water)
    position = find_random_walkable_coordinates_near_player(10,10,5,max_nb_tries = 10)
  elsif $PokemonEncounters.has_cave_encounters?
    encounter_type =   getTimeBasedEncounter(:Cave)
    position = find_random_walkable_coordinates_near_player(10,10,5,max_nb_tries = 10)
  elsif $PokemonEncounters.has_land_encounters?
      encounter_type =   getTimeBasedEncounter(:Land)
      position = find_random_tall_grass_coordinates_near_player(30, 30,5,max_nb_tries = 20)  #todo: only in grass

  end
  return unless encounter_type && position
  wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  create_overworld_pokemon_event(wild_pokemon,position)
end

Events.onMapChange += proc { |_sender, e|
  next unless Settings::HOENN
  if should_spawn_overworld_pokemon?
    spawn_random_overworld_pokemon
  end
}

