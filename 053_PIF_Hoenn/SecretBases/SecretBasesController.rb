class Trainer
  attr_accessor :secretBase
  attr_accessor :owned_decorations
end
def getSecretBaseType(terrainTag)
  return :TREE if terrainTag.secretBase_tree
  #todo: other types
  return nil
end


#todo
def getSecretBaseMapId(baseType)
  case baseType
  when :TREE
    return 65
  end
end

def getSecretBaseEntrance(baseType, mapId)
  return [12,15] #todo
end

def pbSecretBase(base_type, base_map_id, base_entrance_coordinates)
  player_map_id = $game_map.map_id
  player_position = [$game_player.x, $game_player.y]

  if secretBaseExistsAtPosition(player_map_id, player_position)
    enterSecretBase
  else
    # Todo: Determine the secret base's map ids and coordinates from a seed using the current map and the base type instead of passing it manually.
    createSecretBaseHere(base_type, base_map_id, base_entrance_coordinates)
  end
end

def secretBaseExistsAtPosition(map_id, position)
  return false unless $Trainer.secretBase
  current_outdoor_id = $Trainer.secretBase.outside_map_id
  current_outdoor_coordinates = $Trainer.secretBase.outside_entrance_position
  return current_outdoor_id == map_id && current_outdoor_coordinates == position
end

def createSecretBaseHere(type, secretBaseMap = 0, secretBaseCoordinates = [0, 0])
  if pbConfirmMessage("Do you want to create a new secret base here?")
    if $Trainer.secretBase
      unless pbConfirmMessage("This will overwrite your current secret base. Do you still wish to continue?")
        return
      end
    end
    current_map_id = $game_map.map_id
    current_position = [$game_player.x, $game_player.y]
    $Trainer.secretBase = initialize_secret_base(type, current_map_id, current_position, secretBaseMap, secretBaseCoordinates)
    setupSecretBaseEntranceEvent
  end
end

def initialize_secret_base(base_type, outside_map_id, outside_position, base_map_id, base_entrance_position)
  return SecretBase.new(
    base_type,
    outside_map_id,
    outside_position,
    base_map_id,
    base_entrance_position
  )
end

def exitSecretBase()
  return if isMovingFurniture?
  pbStartOver if !$Trainer.secretBase || !$Trainer.secretBase.outside_map_id || !$Trainer.secretBase.outside_entrance_position
  # Should never happen, but just in case

  outdoor_id = $Trainer.secretBase.outside_map_id
  outdoor_coordinates = $Trainer.secretBase.outside_entrance_position
  $PokemonTemp.pbClearTempEvents
  pbFadeOutIn {
    $game_temp.player_new_map_id = outdoor_id
    $game_temp.player_new_x = outdoor_coordinates[0]
    $game_temp.player_new_y = outdoor_coordinates[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
  $PokemonTemp.pbClearTempEvents
  setupSecretBaseEntranceEvent
end

def enterSecretBase()
  $PokemonTemp.pbClearTempEvents
  base_map_id = $Trainer.secretBase.inside_map_id
  base_entrance_position = $Trainer.secretBase.inside_entrance_position

  pbFadeOutIn {
    $game_temp.player_new_map_id = base_map_id
    $game_temp.player_new_x = base_entrance_position[0]
    $game_temp.player_new_y = base_entrance_position[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end

def loadSecretBaseFurniture()
  return unless $Trainer.secretBase
  return unless $scene.is_a?(Scene_Map)
  $Trainer.secretBase.layout.items.each do |item_instance|
    next unless item_instance
    next unless GameData::SECRET_BASE_ITEMS[item_instance.itemId]

    template = item_instance.itemTemplate
    event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_FURNITURE, $game_map.map_id, item_instance.position, DIRECTION_DOWN)
    event.character_name = "player/SecretBases/#{template.graphics}"
    event.through = template.pass_through
    event.under_player = template.under_player
    item_instance.setEventId(event.id)
    event.refresh
  end
end

def secretBaseFurnitureInteract(position = [])
  item = $Trainer.secretBase.layout.get_item_at_position(position)
  item.interact
end

def placeSecretBaseFurniture()
  # todo
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
  if item_id
    new_item_instance = $Trainer.secretBase.layout.add_item(item_id, [$game_player.x, $game_player.y])
    loadSecretBaseFurniture
    $game_temp.original_direction = $game_player.direction
    $game_player.direction = DIRECTION_DOWN
    moveSecretBaseItem(new_item_instance, nil)
  end
end

def selectPlacedSecretBaseItemInstance()
  options = []
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = GameData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.secretBase.layout.items.each do |item_instance|
    item_id = item_instance.itemId
    item_name = GameData::SECRET_BASE_ITEMS[item_id].real_name
    return item_instance if item_name == options[chosen]
  end
  return nil
end

def selectAnySecretBaseItem()
  options = []
  $Trainer.owned_decorations = [] if $Trainer.owned_decorations.nil?
  $Trainer.owned_decorations.each do |item_id|
    item_name = GameData::SECRET_BASE_ITEMS[item_id].real_name
    options << item_name
  end
  options << _INTL("Cancel")
  chosen = optionsMenu(options)
  $Trainer.owned_decorations.each do |item_id|
    item_name = GameData::SECRET_BASE_ITEMS[item_id].real_name
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
def moveSecretBaseItem(itemInstanceId, oldPosition = [0, 0])

  itemInstance = $Trainer.secretBase.layout.get_item_by_id(itemInstanceId)

  event = itemInstance.getEvent

  $game_player.setPlayerGraphicsOverride("SecretBases/#{itemInstance.getGraphics}")
  $game_player.direction_fix = true
  $game_player.under_player = event.under_player
  $game_player.through = event.through  #todo: Make it impossible to go past the walls
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
    placeFurnitureAtCurrentPosition($game_temp.moving_furniture)
  when cmd_rotate
    rotateFurniture
    placeFurnitureMenu(choice)
  when cmd_reset
    return # todo
  when cmd_cancel

  end
end

def placeFurnitureAtCurrentPosition(furnitureInstanceId)
  itemInstance = $Trainer.secretBase.layout.get_item_by_id(furnitureInstanceId)
  itemInstance.position = [$game_player.x, $game_player.y]
  event = itemInstance.getEvent
  event.direction = $game_player.direction

  $PokemonTemp.pbClearTempEvents
  loadSecretBaseFurniture

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


#Called on map load
def setupSecretBaseEntranceEvent
  $PokemonTemp.pbClearTempEvents
  warpPosition = $Trainer.secretBase.outside_entrance_position
  entrancePosition = [warpPosition[0], warpPosition[1]-1]
  event = $PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_TREE, $game_map.map_id, entrancePosition)
  event.refresh

end

Events.onMapSceneChange += proc { |_sender, e|
  next unless $PokemonTemp.tempEvents.empty?
  if $Trainer && $Trainer.secretBase && $game_map.map_id == $Trainer.secretBase.outside_map_id
    setupSecretBaseEntranceEvent
  end
}