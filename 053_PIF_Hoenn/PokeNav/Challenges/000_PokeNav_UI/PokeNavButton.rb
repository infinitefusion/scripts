#===============================================================================
#
#===============================================================================
class PokenavButton < SpriteWrapper
  DESC_Y = 10
  LINE_HEIGHT = 22
  REWARD_LINE = DESC_Y + LINE_HEIGHT * 2

  attr_reader :id

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
    super(viewport)

    @id = id
    @selected = false
    @text = text || get_text
    @crop_width = nil
    @crop_height = nil

    # Determine source bitmap
    if image.is_a?(String)
      @source_bitmap = AnimatedBitmap.new(image)
      bmp = @source_bitmap.bitmap
    elsif image.is_a?(AnimatedBitmap)
      @source_bitmap = image
      bmp = image.bitmap
    elsif image.is_a?(Bitmap)
      bmp = image
    else
      bmp = nil
    end

    # Create display bitmap
    if bmp
      self.bitmap = Bitmap.new(bmp.width, bmp.height)
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    else
      create_empty_bitmap
    end
    refresh
  end




  def create_empty_bitmap
    self.bitmap = Bitmap.new(get_width, get_height)
    pbSetSystemFont(self.bitmap)
  end


  def x=(value)
    @x = value
    super(value)
  end

  def y=(value)
    @y = value
    super(value)
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
    super
  end

  def dispose_source
    @source_bitmap.dispose if @source_bitmap
    @source_bitmap = nil
  end

  def click
    echoln "clicked #{@id}"
  end

  def hover
    echoln "hovering over #{@id}"
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    return unless self.bitmap
    self.bitmap.clear

    if @source_bitmap
      bmp = @source_bitmap.bitmap
      width = @crop_width || bmp.width
      height = @crop_height || bmp.height
      self.bitmap.blt(0, 0, bmp, Rect.new(0, 0, width, height))
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
