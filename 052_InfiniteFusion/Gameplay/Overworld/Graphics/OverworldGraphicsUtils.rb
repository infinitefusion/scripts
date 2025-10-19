def displayPicture(image, x, y, z = 0)
  pictureWindow = PictureWindow.new(image)
  pictureWindow.z = z
  pictureWindow.x = x
  pictureWindow.y = y
  pictureWindow.opacity = 0
  return pictureWindow
end

def showPokemonInPokeballWithMessage(pif_sprite, message, x_position = nil, y_position = nil)
  x_position = Graphics.width / 4 if !x_position
  y_position = 10 if !y_position

  background_sprite = displayPicture("Graphics/Pictures/Trades/trade_pokeball_open_back", x_position, y_position, 1)
  foreground_sprite = displayPicture("Graphics/Pictures/Trades/trade_pokeball_open_front", x_position, y_position, 9999)
  displaySpriteWindowWithMessage(pif_sprite, message, 90, -10, 201)
  background_sprite.dispose
  foreground_sprite.dispose
end

def set_player_graphics(name)
  $game_player.setPlayerGraphicsOverride(name)
  $game_map.refresh
end

def reset_player_graphics()
  $game_player.removeGraphicsOverride
end


def get_spritecharacter_for_event(event_id)
  for sprite in $scene.spriteset.character_sprites
    if sprite.character.id == event_id
      return sprite
    end
  end
end

def get_player_sprite_character
  return nil if !$scene || !$scene.spriteset
  for sprite in $scene.spriteset.character_sprites
    if sprite.is_a?(Game_Player)
      return sprite
    end
  end
  return nil
end

def remove_player_shadow
  #Todo
end

def add_player_shadow
  #Todo
end