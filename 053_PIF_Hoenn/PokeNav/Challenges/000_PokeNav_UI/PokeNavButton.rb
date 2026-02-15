#===============================================================================
#
#===============================================================================
class PokenavButton < SpriteWrapper
  DESC_Y = 10
  LINE_HEIGHT = 22
  REWARD_LINE = DESC_Y + LINE_HEIGHT * 2

  attr_accessor :height
  attr_accessor :width
  attr_accessor :image_path
  attr_accessor :source_bitmap
  attr_accessor :x
  attr_accessor :y
  attr_accessor :crop_width
  attr_accessor :crop_height

  DEFAULT_WIDTH = 20
  DEFAULT_HEIGHT = 20

  def initialize(id, image = nil, text = nil, viewport = nil)
    if image.is_a?(String)
      image_path = image
    elsif image.is_a?(AnimatedBitmap)
      @source_bitmap = image
    end
    super(viewport)
    @crop_width = nil
    @crop_height = nil
    @id = id
    @selected = false
    @text = text || get_text

    # Create a base bitmap no matter what
    if image_path && image_path != ""
      @source_bitmap = AnimatedBitmap.new(image_path) unless @source_bitmap
      bmp = @source_bitmap.bitmap
      self.bitmap = Bitmap.new(bmp.width, bmp.height)
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    else
      create_empty_bitmap
    end

    load_cursor
    refresh
  end



  def create_empty_bitmap
    self.bitmap = Bitmap.new(get_width, get_height)
    pbSetSystemFont(self.bitmap)
  end

  def load_cursor
    return unless cursor_path
    @cursor_bitmap = AnimatedBitmap.new(cursor_path)
  end



  def x=(value)
    @x = value
    super(value)
  end

  def y=(value)
    @y = value
    super(value)
  end


  def cursor_path
    return nil
  end

  def get_height
    return DEFAULT_HEIGHT
  end

  def get_width
    return DEFAULT_WIDTH
  end

  def get_default_image_path
    return ""
  end

  def get_text
    return ""
  end

  def dispose
    dispose_source
    @cursor_bitmap.dispose if @cursor_bitmap
    super
  end

  def dispose_source
    @source_bitmap.dispose if @source_bitmap
    @source_bitmap = nil
  end



  def click
    return
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    return unless self.bitmap
    self.bitmap.clear

    # Draw base image
    if @source_bitmap
      bmp = @source_bitmap.bitmap
      width = @crop_width || bmp.width
      height = @crop_height || bmp.height
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, width, height))
    end

    # Draw selection overlay if exists
    if @selected && @cursor_bitmap
      cur = @cursor_bitmap.bitmap
      self.bitmap.blt(0, 0, cur, Rect.new(0, 0, cur.width, cur.height))
    end

    draw_text if @text && @text != ""
  end


  # Helper method to wrap text into multiple lines
  def wrap_text(text, bitmap, max_width)
    words = text.split(" ")
    lines = []
    line = ""
    words.each do |word|
      test_line = line.empty? ? word : "#{line} #{word}"
      if bitmap.text_size(test_line).width > max_width
        lines << line
        line = word
      else
        line = test_line
      end
    end
    lines << line unless line.empty?
    return lines
  end
end
