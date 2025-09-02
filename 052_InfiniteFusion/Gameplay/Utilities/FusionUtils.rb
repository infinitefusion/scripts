def reverseFusionSpecies(species)
  dexId = getDexNumberForSpecies(species)
  return species if dexId <= NB_POKEMON
  return species if dexId > (NB_POKEMON * NB_POKEMON) + NB_POKEMON
  body = getBasePokemonID(dexId, true)
  head = getBasePokemonID(dexId, false)
  newspecies = (head) * NB_POKEMON + body
  return getPokemon(newspecies)
end

def replaceFusionSpecies(pokemon, speciesToChange, newSpecies)
  currentBody = pokemon.species_data.get_body_species_symbol()
  currentHead = pokemon.species_data.get_head_species_symbol()
  should_update_body = currentBody == speciesToChange
  should_update_head = currentHead == speciesToChange

  echoln speciesToChange
  echoln currentBody
  echoln currentHead

  return if !should_update_body && !should_update_head

  newSpeciesBody = should_update_body ? newSpecies : currentBody
  newSpeciesHead = should_update_head ? newSpecies : currentHead

  newSpecies = getFusionSpecies(newSpeciesBody, newSpeciesHead)
  echoln newSpecies.id_number
  pokemon.species = newSpecies
end