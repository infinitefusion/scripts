
# Output example
# Clefnair (Clefable) @ Life Orb
# Ability: Magic Guard
# Level: 33
# Fusion: Dragonair
# EVs: 252 HP / 252 SpD / 4 Spe
# Modest Nature
# - Dazzling Gleam
# - Dragon Breath
# - Wish
# - Water Pulse
def exportFusedPokemonForShowdown(pokemon)

  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    head_pokemon_species = pokemon.species_data.head_pokemon
    species_name = head_pokemon_species.name
  else
    species_name = pokemon.species_data.real_name
  end

  if pokemon.item
<<<<<<< HEAD
    nameLine = _INTL("{1} ({2}) @ {3}", pokemon.name, species_name, pokemon.item.name)
  else
    nameLine = _INTL("{1} ({2})", pokemon.name, species_name)
=======
    nameLine = "#{pokemon.name} (#{species_name}) @ #{pokemon.item.name}"
  else
    nameLine = "#{pokemon.name} (#{species_name})"
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
  end

  abilityLine = _INTL("Ability: {1}", pokemon.ability.name)
  levelLine = _INTL("Level: {1}", pokemon.level)

  fusionLine = ""
  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    body_pokemon_species = pokemon.species_data.body_pokemon
    fusionLine = _INTL("Fusion: {1}\n", body_pokemon_species.name)
  end
  evsLine = calculateEvLineForShowdown(pokemon)
<<<<<<< HEAD
  natureLine = "#{GameData::Nature.get(pokemon.nature).real_name} Nature"
  ivsLine = calculateIvLineForShowdown(pokemon)

  move1 = "", move2 = "", move3 = "", move4 = ""
  move1 = _INTL("- {1}", GameData::Move.get(pokemon.moves[0].id).real_name) if pokemon.moves[0]
  move2 = _INTL("- {1}", GameData::Move.get(pokemon.moves[1].id).real_name) if pokemon.moves[1]
  move3 = _INTL("- {1}", GameData::Move.get(pokemon.moves[2].id).real_name) if pokemon.moves[2]
  move4 = _INTL("- {1}", GameData::Move.get(pokemon.moves[3].id).real_name) if pokemon.moves[3]
=======
  natureLine = _INTL("{1} Nature",GameData::Nature.get(pokemon.nature).real_name)
  ivsLine = calculateIvLineForShowdown(pokemon)

  move1 = "", move2 = "", move3 = "", move4 = ""
  move1 = "- #{GameData::Move.get(pokemon.moves[0].id).real_name}"  if pokemon.moves[0]
  move2 = "- #{GameData::Move.get(pokemon.moves[1].id).real_name}" if pokemon.moves[1]
  move3 = "- #{GameData::Move.get(pokemon.moves[2].id).real_name}" if pokemon.moves[2]
  move4 = "- #{GameData::Move.get(pokemon.moves[3].id).real_name}" if pokemon.moves[3]
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b

  ret = nameLine + "\n" +
    abilityLine + "\n" +
    levelLine + "\n" +
    fusionLine +
    evsLine + "\n" +
    natureLine + "\n" +
    ivsLine + "\n" +
    move1 + "\n" +
    move2 + "\n" +
    move3 + "\n" +
    move4 + "\n"

  return ret
end




def calculateEvLineForShowdown(pokemon)
  evsLine = "EVs: "
  evsLine << _INTL("{1} HP /", pokemon.ev[:HP])
  evsLine << _INTL("{1} Atk / ", pokemon.ev[:ATTACK])
  evsLine << _INTL("{1} Def / ", pokemon.ev[:DEFENSE])
  evsLine << _INTL("{1} SpA / ", pokemon.ev[:SPECIAL_ATTACK])
  evsLine << _INTL("{1} SpD / ", pokemon.ev[:SPECIAL_DEFENSE])
  evsLine << _INTL("{1} Spe / ", pokemon.ev[:SPEED])
  return evsLine
end

def calculateIvLineForShowdown(pokemon)
  ivLine = "IVs: "
  ivLine << _INTL("{1} HP / ", pokemon.iv[:HP])
  ivLine << _INTL("{1} Atk / ", pokemon.iv[:ATTACK])
  ivLine << _INTL("{1} Def / ", pokemon.iv[:DEFENSE])
  ivLine << _INTL("{1} SpA / ", pokemon.iv[:SPECIAL_ATTACK])
  ivLine << _INTL("{1} SpD / ", pokemon.iv[:SPECIAL_DEFENSE])
  ivLine << _INTL("{1} Spe", pokemon.iv[:SPEED])
  return ivLine
end



