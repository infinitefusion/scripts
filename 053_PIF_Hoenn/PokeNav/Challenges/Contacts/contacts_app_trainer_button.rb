class ContactsAppTrainerButton < PokenavButton
  IMAGE_TEXT_GAP = 96
  DEFAULT_SPRITE_PATH = "000"

  def get_width
    return Graphics.width
  end

  def get_height
    return 48
  end

  def initialize(id, image = nil, text = nil, viewport = nil)
    @image_path = image
    @image_path = DEFAULT_SPRITE_PATH if @image_path.nil?
    super(id, nil, text, viewport)
    refresh
  end

  def viewport=(vp)
    super(vp)
    create_image_sprite
  end

  def create_image_sprite
    return unless @image_path && self.viewport
    @image_sprite = IconSprite.new(0, 0, self.viewport)
    if @id == BATTLED_TRAINER_RIVAL_KEY
      rival_bitmap = AnimatedBitmap.new(getBaseOverworldSpriteFilename())
      rival_bitmap.bitmap = generateNPCClothedBitmapStatic($Trainer.rival_appearance)
      @image_sprite.setBitmapDirectly(rival_bitmap)
    else
      @image_sprite.setBitmap("Graphics/Characters/#{@image_path}")
    end
    @image_sprite.src_rect.width = (@image_sprite.bitmap.width / 4).round
    @image_sprite.src_rect.height = (@image_sprite.bitmap.height / 4).round
    @image_sprite.src_rect.x = 0
    @image_sprite.src_rect.y = 0
    @image_sprite.z = self.z + 1
  end

  def x=(value)
    super
    @image_sprite&.x = value
  end

  def y=(value)
    super
    frame_h = @image_sprite ? @image_sprite.src_rect.height : 0
    @image_sprite&.y = value + (get_height - frame_h) / 2
  end

  def visible=(value)
    super
    @image_sprite&.visible = value
  end

  def dispose
    @image_sprite&.dispose
    super
  end

  def draw_text(x_offset = 0)
    return unless self.bitmap && @text && @text != ""
    frame_w = @image_sprite ? @image_sprite.src_rect.width : 0
    text_x = IMAGE_TEXT_GAP
    max_width = self.bitmap.width - text_x

    lines = wrap_text(@text, self.bitmap, max_width)

    lines.each_with_index do |line, i|
      y_pos = (get_height / 2) - (LINE_HEIGHT * lines.size / 2) + (LINE_HEIGHT * i)
      self.bitmap.font.color = @shadow_color
      self.bitmap.draw_text(text_x + 1, y_pos + 1, max_width, LINE_HEIGHT, line)
      self.bitmap.font.color = @text_color
      self.bitmap.draw_text(text_x, y_pos, max_width, LINE_HEIGHT, line)
    end
  end
end