# chosen pokemon is returned with this format:
#[[boxID, boxPosition],pokemon]

def pbChoosePokemonPC(positionVariableNumber, pokemonVarNumber, ableProc = nil)
  chosen = nil
  pokemon = nil

  pbFadeOutIn {
    scene = PokemonStorageScene.new
    screen = PokemonStorageScreen.new(scene, $PokemonStorage)
    screen.setFilter(ableProc) if ableProc
    chosen = screen.choosePokemon
    pokemon = $PokemonStorage[chosen[0]][chosen[1]] if chosen
    scene.pbCloseBox
  }
  pbSet(positionVariableNumber, chosen)
  pbSet(pokemonVarNumber, pokemon)
end

def npcTrade(npcPokemon_species, nickname, trainerName, playerPokemonProc)
  chosen_pokemon= pbChoosePokemon(1,2,playerPokemonProc)
  chosen_position = pbGet(1)
  return nil if chosen_position <= -1
  pbStartTrade(chosen_position, npcPokemon_species,nickname,trainerName,0)
end