class Sprite_Bicycle < Sprite_Wearable
  def initialize(player_sprite, action, viewport)
    filename = "Graphics/Characters/player/base/overworld/bicycle/bike"
    super(player_sprite,filename,action,viewport)
    @relative_z = -1
  end

  def animate(action, frame = nil)
    @action = action
    current_frame = @player_sprite.character.pattern if !frame
    direction = @player_sprite.character.direction
    crop_spritesheet(direction, current_frame)
    adjust_layer()
    set_sprite_position(@action, direction, current_frame)
  end

  def crop_spritesheet(direction, current_frame)
    sprite_x = ((current_frame)) * @frameWidth
    sprite_y = ((direction - 2) / 2) * @frameHeight
    @sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
  end

  def set_sprite_position(action, direction, current_frame)
    @sprite.x = @player_sprite.x
    @sprite.y = @player_sprite.y
    @sprite.ox = @player_sprite.ox
    @sprite.oy = @player_sprite.oy
  end

end