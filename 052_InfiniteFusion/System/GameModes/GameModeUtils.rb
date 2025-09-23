def getGameModeFromIndex(index)
<<<<<<< HEAD
  return "Classic" if index == 0
  return "Random" if index == 1
  return "Remix" if index == 2
  return "Expert" if index == 3
  return "Species" if index == 4
  return "Debug" if index == 5
=======
  return _INTL("Classic") if index == 0
  return _INTL("Random") if index == 1
  return _INTL("Remix") if index == 2
  return _INTL("Expert") if index == 3
  return _INTL("Species") if index == 4
  return _INTL("Debug") if index == 5
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
  return ""
end

def getCurrentGameModeSymbol()
  gameMode = :CLASSIC
  if $game_switches[SWITCH_MODERN_MODE]
    gameMode = :REMIX
  end
  if $game_switches[SWITCH_EXPERT_MODE]
    gameMode = :EXPERT
  end
  if $game_switches[SWITCH_SINGLE_POKEMON_MODE]
    pokemon_number = pbGet(VAR_SINGLE_POKEMON_MODE)
    if pokemon_number.is_a?(Integer) && pokemon_number > 0
      gameMode = :SINGLE_SPECIES
    else
      gameMode = :DEBUG
    end
  end
  if $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE]
    gameMode = :RANDOMIZED
  end

  if $game_switches[SWITCH_LEGENDARY_MODE]
    gameMode = :LEGENDARY
  end
  return gameMode
end
