def exportTeamForShowdown()
  message = ""
  for pokemon in $Trainer.party
    message << exportFusedPokemonForShowdown(pokemon)
    message << "\n"
  end
  Input.clipboard = message
end

def exportTeamAsJson
  team_string = ""
  for pokemon in $Trainer.party
    team_string << exportFusedPokemonAsJson(pokemon)
    team_string << "\n"
  end
  return team_string
end

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
    nameLine = _INTL("{1} ({2}) @ {3}", pokemon.name, species_name, pokemon.item.name)
  else
    nameLine = _INTL("{1} ({2})", pokemon.name, species_name)
  end

  abilityLine = _INTL("Ability: {1}", pokemon.ability.name)
  levelLine = _INTL("Level: {1}", pokemon.level)

  fusionLine = ""
  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    body_pokemon_species = pokemon.species_data.body_pokemon
    fusionLine = _INTL("Fusion: {1}\n", body_pokemon_species.name)
  end
  evsLine = calculateEvLineForShowdown(pokemon)
  natureLine = "#{GameData::Nature.get(pokemon.nature).real_name} Nature"
  ivsLine = calculateIvLineForShowdown(pokemon)

  move1 = "", move2 = "", move3 = "", move4 = ""
  move1 = _INTL("- {1}", GameData::Move.get(pokemon.moves[0].id).real_name) if pokemon.moves[0]
  move2 = _INTL("- {1}", GameData::Move.get(pokemon.moves[1].id).real_name) if pokemon.moves[1]
  move3 = _INTL("- {1}", GameData::Move.get(pokemon.moves[2].id).real_name) if pokemon.moves[2]
  move4 = _INTL("- {1}", GameData::Move.get(pokemon.moves[3].id).real_name) if pokemon.moves[3]

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


def exportFusedPokemonAsJson(pokemon)
  data = {}
  data[:species] = pokemon.species.to_s
  data[:name] = pokemon.name
  data[:item] = pokemon.item ? pokemon.item.name : nil
  data[:ability] = pokemon.ability ? pokemon.ability.name : nil
  data[:level] = pokemon.level

  # EVs & IVs (todo: Currently just reusing showdown calculation helpers)
  data[:evs] = calculateEvLineForShowdown(pokemon) # string like "252 HP / 252 SpD / 4 Spe"
  data[:ivs] = calculateIvLineForShowdown(pokemon)

  # Nature
  data[:nature] = GameData::Nature.get(pokemon.nature).id

  # Moves
  moves = []
  pokemon.moves.each do |move_slot|
    next unless move_slot
    moves << GameData::Move.get(move_slot.id).id
  end
  data[:moves] = moves

  return JSON.generate(data)
end

def export_team_as_array
  $Trainer.party.compact.map { |p| export_fused_pokemon_hash(p) }
end

def export_fused_pokemon_hash(pokemon)
  data = {
    species: pokemon.species.to_s,
    name:    pokemon.name,
    item:    (pokemon.item ? pokemon.item.name : nil),
    ability: (pokemon.ability ? pokemon.ability.name : nil),
    level:   pokemon.level,
    # Todo: currently just uses Showdown text info
    evs:     calculateEvLineForShowdown(pokemon),
    ivs:     calculateIvLineForShowdown(pokemon),
    nature:  GameData::Nature.get(pokemon.nature).id.to_s,
    moves:   pokemon.moves.compact.map { |m| GameData::Move.get(m.id).id.to_s }
  }
  return data
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




def build_pokemon_from_json(data)
  poke = Pokemon.new(data[:species].to_sym, data[:level])
  poke.name     = data[:name]
  poke.item     = data[:item] if data[:item]
  poke.ability  = data[:ability]
  poke.nature   = data[:nature].to_sym
  poke.moves    = data[:moves].map { |m| Move.new(m.to_sym) }
  # Todo parse EVs/IVs
  return poke
end

