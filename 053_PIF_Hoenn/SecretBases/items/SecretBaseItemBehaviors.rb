# For more complex item behaviors - to keep things organized

def useSecretBaseMannequin
  # Todo: This is the item that players can use to "place themselves" in the base.
  # When a base has a mannequin, the base will be shared online and
  # the mannequin will appear as the player in other people's games.


  secretBase = getEnteredSecretBase
  if secretBase && secretBase.is_visitor
    interact_other_player(secretBase)
  else
    secret_base_mannequin_menu(secretBase)
  end
  return
end

def secret_base_mannequin_menu(secretBase)
  cmd_share = _INTL("Share your secret base")
  cmd_import = _INTL("Import a friend's secret base")
  cmd_setTeam = _INTL("Set your base's Team")
  cmd_trainerID = _INTL("Copy your Trainer ID")
  cmd_export = _INTL("[DEBUG] Export to clipboard")
  cmd_cancel = _INTL("Cancel")
  commands = [cmd_share, cmd_setTeam, cmd_import,cmd_trainerID]
  commands << cmd_export if $DEBUG
  commands << cmd_cancel
  pbMessage(_INTL("What would you like to do?"))
  choice = optionsMenu(commands)
  case commands[choice]
  when cmd_share
    pbMessage(_INTL("Once you share you base, it may randomly appear in other player's games."))
    pbMessage(_INTL("The other players will be able to see your character's name, your base's layout, your custom message, and battle your team."))
    continue = pbConfirmMessage(_INTL("You can only share your secret base once per day. Would you like to continue and publish your current secret base? (Your game will save automatically afterwards)"))
    if continue
      begin
        exporter = SecretBaseExporter.new
        json = exporter.export_secret_base(secretBase)

        publisher = SecretBasePublisher.new
        publisher.register unless $Trainer.secretBase_uuid
        publisher.upload_base(json)
        pbSEPlay('GUI save choice')
        pbMessage(_INTL("Your secret base was shared successfully!"))
      rescue Exception => e
        echoln e
        pbMessage(_INTL("There was a problem uploading your Secret Base. The operation was cancelled."))
      end

    end
  when cmd_import
    friend_code = input_friend_code
    if friend_code
      fetcher = SecretBaseFetcher.new
      begin
        fetcher.import_friend_base(friend_code)
        pbMessage(_INTL("Your friend's base was imported!"))
      rescue
        pbMessage(_INTL("There was a problem, your friend's secret base was not imported."))
      end
    end
  when cmd_setTeam
  when cmd_trainerID
      Input.clipboard = $Trainer.id.to_s
      pbMessage(_INTL("Your Trainer ID was copied to the clipboard!"))
  when cmd_export
    exporter = SecretBaseExporter.new
    json = exporter.export_secret_base($Trainer.secretBase)
    Input.clipboard = json
  end
end

def input_friend_code()
  example = showPicture("Graphics/Pictures/Trainer Card/trainerID_example",0,0,0)

  cmd_refresh = _INTL("Refresh")
  cmd_confirm = _INTL("Confirm")
  cmd_manual = _INTL("Enter manually")
  cmd_cancel = _INTL("Cancel")
  loop do
    commands = []
    clipboard_text = Input.clipboard || ""
    clipboard_text = clipboard_text.slice(0, 10)

    if numeric_string?(clipboard_text)
      message = _INTL("Is this your friend's Trainer ID? \\C[1]#{clipboard_text}\\C[0]")
      commands << cmd_refresh
      commands << cmd_confirm
      commands << cmd_manual
      commands << cmd_cancel
    else
      message = _INTL("Copy your friend's Trainer ID and select 'Refresh'.")
      commands << cmd_refresh
      commands << cmd_manual
      commands << cmd_cancel
    end

    choice = pbMessage(message, commands,commands.length)
    case commands[choice]
    when cmd_refresh
      next
    when cmd_confirm
      example.dispose
      return clipboard_text
    when cmd_manual
      friend_trainer_id = pbEnterText("Friend's Trainer ID", 10, 10, clipboard_text)
      unless numeric_string?(friend_trainer_id)
        pbMessage(_INTL("The Trainer ID you entered is not valid. Trainer IDs are composed of 10 numbers."))
      end
      Input.clipboard = friend_trainer_id
    else
      example.dispose
      return nil
    end
  end
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