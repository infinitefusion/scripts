class ContactsAppTrainerButton < PokenavButton
  IMAGE_TEXT_GAP = 128
  DEFAULT_SPRITE_PATH = "000"
  IMAGE_X_OFFSET = 32
  SOURCE_IMAGE_Y_CROP = 24

  TRADE_AVAILABLE_ICON = "Graphics/Pictures/Pokegear/Trainers/tradeIcon"
  IS_NEW_ICON = "Graphics/Pictures/Pokegear/Trainers/dialogIcon"



  def get_width
    return Graphics.width-72
  end

  def get_height
    return 56
  end

  def background_image
    return "Graphics/Pictures/Pokegear/Trainers/trainer_list_button.png"
  end

  def set_trade_available(value)
    @is_trade_available = true #value
  end

  def set_new(value)
    @is_new = value
  end

  def initialize(id, image = nil, text = nil, viewport = nil)
    @image_path = image
    @image_path = DEFAULT_SPRITE_PATH if @image_path.nil?
    super(id, nil, text, viewport)
    @is_trade_available = false
    @is_new = false
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
    frame_w = (@image_sprite.bitmap.width / 4).round
    frame_h = (@image_sprite.bitmap.height / 4).round

    @image_sprite.src_rect.width  = frame_w
    @image_sprite.src_rect.height = [frame_h - SOURCE_IMAGE_Y_CROP, get_height].min
    @image_sprite.src_rect.x = 16
    @image_sprite.src_rect.y = 16
    @image_sprite.z = self.z + 1
  end
  def x=(value)
    super
    @image_sprite&.x = value + IMAGE_X_OFFSET
  end

  def y=(value)
    super
    frame_h = @image_sprite ? @image_sprite.src_rect.height : 0
    @image_sprite&.y = value + (get_height - frame_h) / 2 - 8
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