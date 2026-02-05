class Clothes < Outfit
  attr_accessor :type
  def initialize(id, name, description = '',price=0, tags = [], store_locations = [])
    super
    @type = :CLOTHES
  end

  def trainer_sprite_path()
    return getTrainerSpriteOutfitFilename(self.id)
  end
end