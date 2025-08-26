# frozen_string_literal: true

# wrapper for secret base items

class SecretBaseItem
  attr_reader :id # Symbol. Used for manipulating in other classes (trainer.unlockedBaseItems is an array of these, etc.)
  attr_reader :graphics # File path to the item's graphics
  attr_reader :real_name # Name displayed in-game
  attr_reader :price

  # Event attributes
  attr_reader :pass_through # for carpets, etc.
  attr_reader :under_player # for carpets, etc.

  # Secret base object attributes
  attr_reader :deletable
  attr_reader :behavior # Lambda function that's defined when initializing the items. Some secret bases can have special effects when you interact with them (ex: a berry pot to grow berries, a bed, etc.)
  # -> This is the function that will be called when the player interacts with the item in the base.
  # Should just display flavor text for most basic items.

  def initialize(id:, graphics:, real_name:, price:, deletable: true, pass_through: false, under_player: false, behavior: nil)
    @id = id
    @graphics = graphics
    @real_name = real_name
    @price = price
    @deletable = deletable
    @pass_through = pass_through
    @under_player = under_player
    # Default behavior just shows text if none provided
    @behavior = behavior
  end

end
