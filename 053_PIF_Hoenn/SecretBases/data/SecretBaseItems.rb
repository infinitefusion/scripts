# frozen_string_literal: true
module SecretBasesData

  SECRET_BASE_ITEMS = {}

  def SecretBasesData::register_base_item(id, **kwargs)
    SECRET_BASE_ITEMS[id] = SecretBaseItem.new(id: id, **kwargs)
  end

  register_base_item(
    :PC,
    graphics: "Furniture/pc.png",
    real_name: "PC",
    deletable: false,
    price: 0,
    behavior: ->(event = nil) {
      #Behavior for PC is handled in SecretBasesController
      #useSecretBasePC
    }
  )

  register_base_item(
    :MANNEQUIN,
    graphics: "Furniture/mannequin.png",
    real_name: "Mannequin",
    price: 500,
    behavior: ->(event = nil) {
      useSecretBaseMannequin
    }

  )

  register_base_item(
    :PLANT,
    graphics: "Furniture/plant.png",
    real_name: "Decorative Plant",
    price: 500
  )

  register_base_item(
    :RED_CHAIR,
    graphics: "Furniture/red_chair.png",
    real_name: "Red Chair",
    price: 350,
    under_player: true,
    behavior: ->(itemInstance = nil) {
      event=itemInstance.getEvent
      pbSEPlay("jump", 80, 100)
      $game_player.through =true
      $game_player.jump_forward
      case event.direction
      when DIRECTION_LEFT; $game_player.direction = DIRECTION_RIGHT
      when DIRECTION_RIGHT; $game_player.direction = DIRECTION_LEFT
      when DIRECTION_UP; $game_player.direction = DIRECTION_UP
      when DIRECTION_DOWN; $game_player.direction = DIRECTION_DOWN
      end
      $game_player.through =false
    }
  )

  register_base_item(
    :FANCY_CARPET,
    graphics: "Carpets/fancy_carpet.png",
    real_name: "Fancy Carpet",
    price: 5000,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :FANCY_CARPET_CONNECT,
    graphics: "Carpets/fancy_carpet_connect.png",
    real_name: "Fancy Carpet (Connection)",
    price: 100,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :BOULDER,
    graphics: "Furniture/boulder.png",
    real_name: "Boulder",
    price: 600,
    under_player: false,
    behavior: ->(itemInstance = nil) {
      pbStrength
      if $PokemonMap.strengthUsed
        pushEvent(itemInstance)
      end
    }
  )

end

