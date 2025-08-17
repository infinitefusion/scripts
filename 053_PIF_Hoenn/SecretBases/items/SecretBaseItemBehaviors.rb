#For more complex item behaviors - to keep things organized
def useSecretBasePC()
  pbMessage(_INTL("\\se[PC open]{1} booted up the PC.",$Trainer.name))
  cmd_furnish = _INTL("Add decorations")
  cmd_storage = _INTL("Pokémon Storage")
  cmd_item_storage = _INTL("Item Storage")
  cmd_cancel = _INTL("Cancel")

  commands = []
  commands << cmd_furnish
  commands << cmd_storage
  commands << cmd_item_storage

  choice = optionsMenu(commands)
  case commands[choice]
  when cmd_furnish
    return
  when cmd_storage
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0) # Boot PC in organize mode
    }
  when cmd_item_storage
    pbPCItemStorage
  when cmd_cancel
    return
  end
end


