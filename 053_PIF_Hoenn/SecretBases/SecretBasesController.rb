SWITCH_SECRET_BASE_PLACED_FIRST_DECORATION = 2047

class Trainer
  attr_accessor :secretBase
  attr_accessor :owned_decorations
end

class PokemonTemp
  attr_accessor :enteredSecretBaseController
end

class SecretBaseController
  attr_accessor :secretBase

  def initialize(secretBase)
    @secretBase = secretBase
  end

  def furnitureInteract(position = [])
    item = @secretBase.layout.get_item_at_position(position)

    cmd_use = _INTL("Use")
    cmd_move = _INTL("Move")
    cmd_delete = _INTL("Put away")
    cmd_cancel = _INTL("Cancel")
    cmd_decorate = _INTL("Decorate!")
    cmd_storage = _INTL("Pokémon Storage")
    cmd_item_storage = _INTL("Item Storage")

    options = []
    if item.itemId == :PC
      pbMessage(_INTL("\\se[PC open]{1} booted up the PC.", $Trainer.name))
      options << cmd_decorate unless @secretBase.is_visitor
      options << cmd_storage
      options << cmd_item_storage
    else
      options << cmd_use if item.itemTemplate.behavior
    end
    options << cmd_move unless @secretBase.is_visitor
    options << cmd_delete if item.itemTemplate.deletable && !@secretBase.is_visitor
    options << cmd_cancel

    # --- Auto-execute if only one actionable option (ignoring cancel) ---
    actionable = options - [cmd_cancel]
    if actionable.length == 1
      return executeFurnitureCommand(item, actionable.first)
    end

    # Otherwise, show the menu
    choice = optionsMenu(options)
    executeFurnitureCommand(item, options[choice], position)
  end

  # Extracted for clarity
  def executeFurnitureCommand(item, command, position = nil)
    case command
    when _INTL("Use")
      item.itemTemplate.behavior.call
    when _INTL("Move")
      moveSecretBaseItem(item.instanceId, item.position)
    when _INTL("Put away")
      # TODO: implement delete behavior
    when _INTL("Decorate!")
      decorateSecretBase
    when _INTL("Pokémon Storage")
      pbFadeOutIn {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(0) # Boot PC in organize mode
      }
    when _INTL("Item Storage")
      pbPCItemStorage
    end
  end

  def isMovingFurniture?
    return $game_temp.moving_furniture
  end

  def decorateSecretBase
    cmd_addItem = _INTL("Add a decoration")
    cmd_moveItem = _INTL("Move a decoration")
    cmd_cancel = _INTL("Back")

    commands = []
    commands << cmd_addItem
    commands << cmd_moveItem
    commands << cmd_cancel

    choice = optionsMenu(commands)
    case commands[choice]
    when cmd_addItem
      item_id = selectAnySecretBaseItem
      addSecretBaseItem(item_id)
    when cmd_moveItem
      item_instance = selectPlacedSecretBaseItemInstance
      moveSecretBaseItem(item_instance.instanceId, item_instance.position)
    when cmd_cancel
      return
    end
  end

  def addSecretBaseItem(item_id)
    return if @secretBase.is_a?(VisitorSecretBase)
    echoln "ADDING ITEM #{item_id}"
    if item_id
      new_item_instance = $Trainer.secretBase.layout.add_item(item_id, [$game_player.x, $game_player.y])
      SecretBaseLoader.new.loadSecretBaseFurniture(@secretBase)
      $game_temp.original_direction = $game_player.direction
      $game_player.direction = DIRECTION_DOWN
      moveSecretBaseItem(new_item_instance, nil)
    end
  end

  def moveSecretBaseItem(itemInstanceId, oldPosition = [0, 0])
    return if @secretBase.is_a?(VisitorSecretBase)
    itemInstance = @secretBase.layout.get_item_by_id(itemInstanceId)

    event = itemInstance.getEvent

    $game_player.setPlayerGraphicsOverride("SecretBases/#{itemInstance.getGraphics}")
    $game_player.direction_fix = true
    $game_player.under_player = event.under_player
    $game_player.through = event.through # todo: Make it impossible to go past the walls
    $game_temp.moving_furniture = itemInstanceId
    $game_temp.moving_furniture_oldPlayerPosition = [$game_player.x, $game_player.y]
    $game_temp.moving_furniture_oldItemPosition = itemInstance.position

    event.opacity = 50 if event
    event.through = true if event

    $game_player.x, $game_player.y = itemInstance.position
    $game_system.menu_disabled = true
    $game_map.refresh
  end

  def cancelMovingFurniture()
    $game_system.menu_disabled = false
    $game_player.removeGraphicsOverride()
    $game_temp.moving_furniture = nil
  end

  def placeFurnitureMenu(menu_position = 0)
    if !$Trainer.secretBase || !$game_temp.moving_furniture
      cancelMovingFurniture()
    end

    cmd_place = _INTL("Place here")
    cmd_rotate = _INTL("Rotate")
    cmd_reset = _INTL("Reset")
    cmd_cancel = _INTL("Cancel")

    options = []
    options << cmd_place
    options << cmd_rotate
    options << cmd_reset
    options << cmd_cancel

    choice = optionsMenu(options, -1, menu_position)
    case options[choice]
    when cmd_place
      placeFurnitureAtCurrentPosition($game_temp.moving_furniture, $game_player.direction)
    when cmd_rotate
      rotateFurniture
      placeFurnitureMenu(choice)
    when cmd_reset
      return # todo
    when cmd_cancel

    end
  end

  def placeFurnitureAtCurrentPosition(furnitureInstanceId, direction)
    $game_switches[SWITCH_SECRET_BASE_PLACED_FIRST_DECORATION] = true
    itemInstance = $Trainer.secretBase.layout.get_item_by_id(furnitureInstanceId)
    itemInstance.position = [$game_player.x, $game_player.y]
    itemInstance.direction = direction
    event = itemInstance.getEvent
    event.direction = $game_player.direction

    $PokemonTemp.pbClearTempEvents
    SecretBaseLoader.new.loadSecretBaseFurniture(@secretBase)

    # Roload after items update
    itemInstance = $Trainer.secretBase.layout.get_item_by_id(furnitureInstanceId)
    event = itemInstance.getEvent
    event.direction = $game_player.direction

    $game_player.removeGraphicsOverride
    pbFadeOutIn {
      $game_player.direction_fix = false
      if $game_temp.original_direction
        $game_player.direction = $game_temp.original_direction
      end
      $game_player.through = false
      $game_player.under_player = false
      $game_temp.player_new_map_id = $game_map.map_id
      $game_temp.player_new_x = $game_temp.moving_furniture_oldPlayerPosition[0]
      $game_temp.player_new_y = $game_temp.moving_furniture_oldPlayerPosition[1]
      $scene.transfer_player(true)
      $game_map.autoplay
      $game_map.refresh
    }
    $game_temp.moving_furniture_oldPlayerPosition = nil
    $game_temp.moving_furniture_oldItemPosition = nil
    $game_temp.moving_furniture = nil
    $game_system.menu_disabled = false
  end

  def rotateFurniture()
    $game_player.direction_fix = false
    $game_player.turn_right_90
    $game_player.direction_fix = true
  end

end

def getEnteredSecretBase
  controller = $PokemonTemp.enteredSecretBaseController
  return controller.secretBase if controller
end

def getSecretBaseController
  return $PokemonTemp.enteredSecretBaseController
end

def selectPlacedSecretBaseItemInstance()
  options = []
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    return item_instance if item_name == options[chosen]
  end
  return nil
end

def selectAnySecretBaseItem()
  options = []
  $Trainer.owned_decorations = [] if $Trainer.owned_decorations.nil?
  $Trainer.owned_decorations.each do |item_id|
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.owned_decorations.each do |item_id|
    item_name = SecretBasesData::SECRET_BASE_ITEMS[item_id].real_name
    return item_id if item_name == options[chosen]
  end
  return nil
end

# Save player position
# Change character graphics to item graphics
# Make current invisible
# Enter "moving mode" :
# Press A :
#   Options:
#  - Place here: Sets the item with the instance ID to the current position & reloads map
#       (check if passable, not already used by another item, not the saved player position)
#  -Cancel: closes menu, reloads map
# Press B: Exit moving mode

# todo: cancel! (delete the item when cancel if oldPosition is nil (when adding a new item))

#