class Trainer
  attr_accessor :secretBase
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
      unless pbConfirmMessage("This will overwrite your secret base in #{$Trainer.secretBase.location_name}. Do you still wish to continue?")
        return
      end
    end
    current_map_id = $game_map.map_id
    current_position = [$game_player.x, $game_player.y]
    $Trainer.secretBase = initialize_secret_base(type, current_map_id, current_position, secretBaseMap, secretBaseCoordinates)
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
  pbStartOver if !$Trainer.secretBase || !$Trainer.secretBase.outside_map_id || !$Trainer.secretBase.outside_entrance_position
  # Should never happen, but just in case

  outdoor_id = $Trainer.secretBase.outside_map_id
  outdoor_coordinates = $Trainer.secretBase.outside_entrance_position
  pbFadeOutIn {
    $game_temp.player_new_map_id = outdoor_id
    $game_temp.player_new_x = outdoor_coordinates[0]
    $game_temp.player_new_y = outdoor_coordinates[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
  $PokemonTemp.pbClearAllTempEvents
end

def enterSecretBase()
  $PokemonTemp.pbClearAllTempEvents
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

def moveSecretBaseItem(itemInstanceId,oldPosition=[0,0])
  #Save player position
  #Change character graphics to item graphics
  #Make current invisible
  #Enter "moving mode" :
  # Press A :
  #   Options:
  #  - Place here: Sets the item with the instance ID to the current position & reloads map
  #       (check if passable, not already used by another item, not the saved player position)
  #  -Cancel: closes menu, reloads map
  # Press B: Exit moving mode
  itemInstance = $Trainer.secretBase.layout.get_item_by_id(itemInstanceId)
end


def loadSecretBaseFurniture()
  return if !$Trainer.secretBase

  $Trainer.secretBase.layout.items.each do |item_instance|
    next unless item_instance
    next unless GameData::SECRET_BASE_ITEMS[item_instance.itemId]


    event =$PokemonTemp.createTempEvent(TEMPLATE_EVENT_SECRET_BASE_FURNITURE,$game_map.map_id, item_instance.position)
    event.character_name = item_instance.itemTemplate.graphics
    event.refresh
  end
end

def secretBaseFurnitureInteract(position=[])
  item = $Trainer.secretBase.layout.get_item_at_position(position)
  item.interact
end

def placeSecretBaseFurniture()
  #todo
end