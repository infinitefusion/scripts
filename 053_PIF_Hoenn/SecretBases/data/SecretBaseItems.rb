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
    behavior: -> {
      useSecretBasePC
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

end

