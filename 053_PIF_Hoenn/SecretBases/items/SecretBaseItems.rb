# frozen_string_literal: true
module GameData

  SECRET_BASE_ITEMS = {}

  def GameData::register_base_item(id, **kwargs)
    SECRET_BASE_ITEMS[id] = SecretBaseItem.new(id: id, **kwargs)
  end

  register_base_item(
    :PC,
    graphics: "/SecretBases/Furniture/pc.png",
    real_name: "PC",
    deletable: false,
    price: 0,
    behavior: -> {
      useSecretBasePC
    }
  )

  register_base_item(
    :PLANT,
    graphics: "/SecretBases/Furniture/plant.png",
    real_name: "Decorative Plant",
    price: 500
  )

  register_base_item(
    :BED,
    graphics: "/SecretBase/bed.png",
    real_name: "Cozy Bed",
    price: 1000,
    behavior: -> {
      pbMessage("You lie down on the bed. It feels soft and comfy.")
      pbFadeOutIn {
        $Trainer.heal_party
        pbMessage("Your Pokémon are fully healed!")
      }
    }
  )

end

