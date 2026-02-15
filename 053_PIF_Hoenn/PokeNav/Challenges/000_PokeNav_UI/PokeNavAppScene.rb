class PokeNavAppScene
  #--------------------------------------------------------------------------
  # Configuration (override in child classes)
  #--------------------------------------------------------------------------
  def display_mode
    return :LIST # :LIST or :GRID
  end

  def start_x
    return 60;
  end

  def start_y
    return 80;
  end

  def x_gap
    return 220;
  end

  def y_gap
    return 100;
  end

  def visible_rows
    return 4;
  end

  def columns
    return (display_mode == :GRID) ? 2 : 1
  end

  # buttons should be a list of PokeNavButton
  def pbStartScene(buttons = [])
    @buttons = buttons
    @index = 0
    @mode = display_mode
    @exit = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    createBackground
    createHeader if use_header?

    @buttons.each_with_index do |b, i|
      b.viewport = @viewport
      @sprites["button#{i}"] = b
    end

    displayTextElements
    layoutButtons

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    layoutButtons
    pbUpdateSpriteHash(@sprites)
  end

  def layoutButtons
    cols = columns
    rows_visible = visible_rows

    # Current selected row
    current_row = @index / cols

    # Scroll offset in rows
    scroll_row = 0
    if current_row >= rows_visible
      scroll_row = current_row - rows_visible + 1
    end

    scroll_pixels = scroll_row * y_gap

    @buttons.each_with_index do |btn, i|
      row = i / cols
      col = i % cols

      btn.x = start_x + col * x_gap
      btn.y = start_y + row * y_gap - scroll_pixels
      btn.visible = (btn.y >= start_y - y_gap && btn.y <= Graphics.height)
      btn.selected = (i == @index)
    end

    updateHeader(scroll_row)
  end

  def createHeader
    @sprites["header"] = IconSprite.new(0, 0, @viewport)
    @sprites["header"].setBitmap("Graphics/Pictures/Challenges/bg_header")
  end

  def createBackground
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if $Trainer.pokenav.darkMode
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_dark")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    end
  end

  def updateHeader(scroll_row)
    return unless use_header?
    return unless @sprites["header"]

    if scroll_row > 0
      Kernel.pbClearText
      @sprites["header"].visible = false
    else
      displayTextElements
      @sprites["header"].visible = true
    end
  end

  def use_header?
    return true
  end


  def displayTextElements
    Kernel.pbClearText
  end

  def pbScene
    loop do
      Graphics.update
      Input.update

      updateInput
      layoutButtons
      pbUpdateSpriteHash(@sprites)

      break if @exit
    end
  end

  def updateInput
    cols = columns
    total = @buttons.length

    if Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @exit = true
      return
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      @buttons[@index]&.click

    elsif Input.trigger?(Input::LEFT) && cols > 1
      move_index(-1)

    elsif Input.trigger?(Input::RIGHT) && cols > 1
      move_index(1)

    elsif Input.trigger?(Input::UP)
      move_index(-cols)

    elsif Input.trigger?(Input::DOWN)
      move_index(cols)
    end
  end

  def move_index(delta)
    return if @buttons.empty?
    pbPlayCursorSE
    @index = (@index + delta) % @buttons.length
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    Kernel.pbClearText
    @viewport.dispose
  end
end
