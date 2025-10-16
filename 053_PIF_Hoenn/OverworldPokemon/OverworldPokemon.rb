# A special type of event that is a Pokemon visible in the overworld. It flees if the player gets too close.
# Can either spawn naturally or be static

OVERWORLD_POKEMON_COMMENT_TRIGGER = "OverworldPokemon"
class OverworldPokemon
  def initialize()
    @pokemon = :PIKACHU # Can only be unfused
    @x = 0
    @y = 0
    @map_id = 0

    @flying = false
    @always_on_top = false
    @stop_animation = false
    @detection_radius = 1

    @flee_graphics = nil # Possible to use a different sprite when fleeing (flying pokemon, etc.)
  end

end

def should_spawn_overworld_pokemon?
  return true
end

def create_overworld_pokemon_event(pokemon,position)
  echoln "trying to spawn #{pokemon} at #{position}"

  event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_OW_POKEMON, $game_map.map_id, position)
  return unless event.detectCommentCommand(OVERWORLD_POKEMON_COMMENT_TRIGGER)
  event.character_name = "Followers/#{pokemon.species}"
  event.id = "OW_#{pokemon.species}_#{pokemon.level.to_s}"
end

def spawn_random_overworld_pokemon
  map_id = $game_map.map_id
  if $PokemonGlobal.surfing && has_water_encounters?
    encounter_type =   getTimeBasedEncounter(:Water)
    position = find_random_walkable_coordinates_near_player(20,20,5,max_nb_tries = 10)
  elsif $PokemonEncounters.has_cave_encounters?
    encounter_type =   getTimeBasedEncounter(:Cave)
    position = find_random_walkable_coordinates_near_player(20,20,5,max_nb_tries = 10)
  elsif $PokemonEncounters.has_land_encounters?
      encounter_type =   getTimeBasedEncounter(:Land)
      position = find_random_walkable_coordinates_near_player(20,20,5,max_nb_tries = 10)  #todo: only in grass

  end
  return unless encounter_type && location
  wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
end

Events.onMapChange += proc { |_sender, e|
  scene = e[0]
  mapChanged = e[1]
  next unless mapChanged
  next unless Settings::HOENN
  if should_spawn_overworld_pokemon?
    spawn_random_overworld_pokemon
  end
}

