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
<<<<<<< HEAD
    real_name: "Mannequin",
=======
    real_name: _INTL("Mannequin"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 500,
    behavior: ->(event = nil) {
      useSecretBaseMannequin
    }

  )

  register_base_item(
    :PLANT,
    graphics: "Furniture/plant.png",
<<<<<<< HEAD
    real_name: "Decorative Plant",
=======
    real_name: _INTL("Decorative Plant"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 500
  )

  register_base_item(
    :RED_CHAIR,
    graphics: "Furniture/red_chair.png",
<<<<<<< HEAD
    real_name: "Red Chair",
=======
    real_name: _INTL("Red Chair"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 350,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    }
  )

  register_base_item(
    :FANCY_CARPET,
    graphics: "Carpets/fancy_carpet.png",
<<<<<<< HEAD
    real_name: "Fancy Carpet",
=======
    real_name: _INTL("Fancy Carpet"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 5000,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :FANCY_CARPET_CONNECT,
    graphics: "Carpets/fancy_carpet_connect.png",
<<<<<<< HEAD
    real_name: "Fancy Carpet (Connection)",
=======
    real_name: _INTL("Fancy Carpet (Connection)"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 100,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :BOULDER,
    graphics: "Furniture/boulder.png",
<<<<<<< HEAD
    real_name: "Boulder",
=======
    real_name: _INTL("Boulder"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 600,
    under_player: false,
    behavior: ->(itemInstance = nil) {
      pbStrength
      if $PokemonMap.strengthUsed
        pushEvent(itemInstance)
      end
    }
  )

  #Skitty set

  register_base_item(
    :SKITTY_CHAIR_3x3,
    graphics: "skittySet/deco_3x3chair_skitty.png",
<<<<<<< HEAD
    real_name: "Skitty Armchair",
=======
    real_name: _INTL("Skitty Armchair"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :SKITTY_CHAIR_3x3,
    graphics: "skittySet/deco_3x3chair_skitty.png",
<<<<<<< HEAD
    real_name: "Skitty Armchair",
=======
    real_name: _INTL("Skitty Armchair"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :SKITTY_COUCH_3x4,
    graphics: "skittySet/deco_3x4chair_skitty.png",
<<<<<<< HEAD
    real_name: "Skitty Couch",
=======
    real_name: _INTL("Skitty Couch"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 2000,
    height: 1,
    width: 4,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-2,0],[2,0]]
  )

  register_base_item(
    :SKITTY_COUCH_3x5,
    graphics: "skittySet/deco_3x5couch_skitty.png",
<<<<<<< HEAD
    real_name: "Wide Skitty Couch",
=======
    real_name: _INTL("Wide Skitty Couch"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 2000,
    height: 1,
    width: 5,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-2,0],[2,0]]
  )

  register_base_item(
    :SKITTY_RUG_3x3,
    graphics: "skittySet/deco_3x3rug_skitty.png",
<<<<<<< HEAD
    real_name: "Large Skitty Rug",
=======
    real_name: _INTL("Large Skitty Rug"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 3000,
    pass_through: true,
    under_player: true
  )

  #Rock set
  register_base_item(
    :ROCK_CHAIR_1x1,
    graphics: "rockSet/deco_1x1chair_rock.png",
<<<<<<< HEAD
    real_name: "Rocky Stool",
=======
    real_name: _INTL("Rocky Stool"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 350,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    }
  )

  register_base_item(
    :ROCK,
    graphics: "rockSet/deco_1x1deco_rock.png",
<<<<<<< HEAD
    real_name: "Rock",
=======
    real_name: _INTL("Rock"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 50
  )

  register_base_item(
    :ROCK_STATUE,
    graphics: "rockSet/deco_1x1statue_rock.png",
<<<<<<< HEAD
    real_name: "Rocky Statue",
=======
    real_name: _INTL("Rocky Statue"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 50
  )

  register_base_item(
    :ROCK_WALL,
    graphics: "rockSet/deco_1x2wall_rock.png",
<<<<<<< HEAD
    real_name: "Rocky Wall",
=======
    real_name: _INTL("Rocky Wall"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 50
  )

  register_base_item(
    :ROCK_TABLE_2x3,
    graphics: "rockSet/deco_2x3table_rock.png",
<<<<<<< HEAD
    real_name: "Large Rocky Table",
=======
    real_name: _INTL("Large Rocky Table"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    width:3,
    height:2,
    price: 5000
  )

  register_base_item(
    :ROCK_CHAIR_3x3,
    graphics: "rockSet/deco_3x3chair_rock.png",
<<<<<<< HEAD
    real_name: "Rocky Armchair",
=======
    real_name: _INTL("Rocky Armchair"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 1000,
    height: 1,
    width: 3,
    trigger: TRIGGER_PLAYER_TOUCH,
    behavior: ->(itemInstance = nil) {
      sit_on_chair(itemInstance)
    },
    uninteractable_positions: [[-1,0],[1,0]]
  )

  register_base_item(
    :ROCK_RUG_1x1,
    graphics: "rockSet/deco_1x1rug_rock.png",
<<<<<<< HEAD
    real_name: "Small Rocky Rug",
=======
    real_name: _INTL("Small Rocky Rug"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 500,
    pass_through: true,
    under_player: true
  )

  register_base_item(
    :ROCK_RUG_3x3,
    graphics: "rockSet/deco_3x3rug_rock.png",
<<<<<<< HEAD
    real_name: "Large Rocky Rug",
=======
    real_name: _INTL("Large Rocky Rug"),
>>>>>>> ccaa263b8eee38abaf4795358201b8c807de803b
    price: 2000,
    pass_through: true,
    under_player: true
  )

end

