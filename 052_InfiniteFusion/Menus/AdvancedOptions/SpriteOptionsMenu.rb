def spriteOptionsMenu
  commands = []
  cmd_manual_update= _INTL("Update sprites manually")
  cmd_clear_sprite_cache = _INTL("Clear sprite cache")
  cmd_reset_alt_sprites  = _INTL("Reset selected sprites")
  cmd_cancel = _INTL("Cancel")
  commands << cmd_manual_update
  commands << cmd_clear_sprite_cache
  commands << cmd_reset_alt_sprites
  commands << cmd_cancel

  chosen = optionsMenu(commands)

  case commands[chosen]
  when cmd_manual_update
    should_update = pbConfirmMessage(_INTL("Would you like to redownload the spritepack's data to make sure that all sprites are correctly updated?"))
    update_spritepack_files if should_update
  when cmd_reset_alt_sprites
    confirmed = pbConfirmMessage(_INTL("Reset the chosen alternate sprites set for every Pokémon?"))
    if confirmed
      $PokemonGlobal.alt_sprite_substitutions=Hash.new
      pbMessage(_INTL("Alt sprites substitutions have been reset."))
    end
  when cmd_clear_sprite_cache
    confirmed = pbConfirmMessage(_INTL("Clear the temporary sprites cache for every Pokémon? Every sprite will be fully reloaded the next time they are shown."))
    if confirmed
      spritesLoader = BattleSpriteLoader.new
      spritesLoader.clear_sprites_cache(:CUSTOM)
      spritesLoader.clear_sprites_cache(:BASE)
      pbMessage(_INTL("The sprites cache was cleared."))
    end
  end
end