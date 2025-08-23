# For more complex item behaviors - to keep things organized

def useSecretBaseMannequin
  # Todo: This is the item that players can use to "place themselves" in the base.
  # When a base has a mannequin, the base will be shared online and
  # the mannequin will appear as the player in other people's games.
  exporter = SecretBaseExporter.new
  json = exporter.export_secret_base($Trainer.secretBase)
  Input.clipboard = json

  secretBase = getEnteredSecretBase
  if secretBase && secretBase.is_visitor
    interact_other_player(secretBase)

  end
  return
end

def interact_other_player(secretBase)
  event = pbMapInterpreter.get_character(0)
  event.direction_fix = false
  event.turn_toward_player
  message = secretBase.base_message
  pbCallBub(3)
  pbMessage(_INTL("Hey, I'm \\C[1]#{secretBase.trainer_name}\\C[0], welcome to my secret base!",))
  if message
    pbCallBub(3)
    pbMessage(message)
  end
end

def pushEvent(itemInstance)
  event = itemInstance.getEvent
  old_x = event.x
  old_y = event.y
  return if !event.can_move_in_direction?($game_player.direction, false)
  case $game_player.direction
  when 2 then event.move_down
  when 4 then event.move_left
  when 6 then event.move_right
  when 8 then event.move_up
  end

  if old_x != event.x || old_y != event.y
    $game_player.lock
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break if !event.moving?
    end
    itemInstance.position = [event.x, event.y]
    $PokemonTemp.pbClearTempEvents
    $PokemonTemp.enteredSecretBaseController.reloadItems

      $game_player.unlock
  end
end

# PC behavior set directly in SecretBaseController