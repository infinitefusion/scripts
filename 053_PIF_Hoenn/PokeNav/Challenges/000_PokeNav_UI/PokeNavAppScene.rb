class PokeNavAppScene


  #--------------------------------------------------------------------------
  # Configuration (override in child classes)
  #--------------------------------------------------------------------------
  HEADER_HEIGHT = -6
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

  def header_path
    return "Graphics/Pictures/Pokegear/bg_header"
  end

  def header_name
    return _INTL("PokeNav App")
  end

  def columns
    return (display_mode == :GRID) ? 2 : 1
  end

  # buttons should be a list of PokeNavButton
  def pbStartScene(buttons = [])
    @buttons = buttons
    @index = 0
    @mode = display_mode
    @exiting = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    createBackground
    createHeader if use_header?

    @buttons.each_with_index do |b, i|
      b.viewport = @viewport
      @sprites["button#{i}"] = b
    end
    createCursor
    layoutButtons

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    layoutButtons
    pbUpdateSpriteHash(@sprites)
  end

  def layoutButtons
    return if @exiting
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
    updateCursor
    updateHeader(scroll_row)
  end

  def updateCursor
    cursor = @sprites["cursor"]
    return unless cursor
    return if @buttons.empty?

    btn = @buttons[@index]
    return unless btn

    cursor.x = btn.x
    cursor.y = btn.y
    cursor.visible = btn.visible
  end

  def cursor_path
    return "Graphics/Pictures/Pokegear/icon_button"
  end

  def createCursor
    return unless cursor_path
    @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["cursor"].setBitmap(cursor_path)
    @sprites["cursor"].z = 100000
  end

  def createHeader
    @sprites["header"] = IconSprite.new(0, 0, @viewport)
    @sprites["header"].setBitmap(header_path)
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
      @sprites["header"].visible = false
    else
      @sprites["header"].visible = true
    end
  end

  def use_header?
    return true
  end

  def displayTextElements
    Kernel.pbClearText
    showHeaderName
  end

  def showHeaderName
    Kernel.pbDisplayText(header_name, Graphics.width/2 , HEADER_HEIGHT)
  end
  def pbScene
    loop do
      Graphics.update
      Input.update

      updateInput
      layoutButtons
      pbUpdateSpriteHash(@sprites)

      break if @exiting
    end
  end

  def updateInput
    cols = columns
    total = @buttons.length

    if Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @exiting = true
      return
    elsif Input.trigger?(Input::USE)
      pbPlayDecisionSE
      click(@buttons[@index]&.id)
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

  def hover(button_id)
    @buttons[@index]&.hover
  end

  def click(button_id)
    @buttons[@index]&.click
  end
  def move_index(delta)
    return if @buttons.empty?
    pbPlayCursorSE
    @index = (@index + delta) % @buttons.length
    hover(@buttons[@index]&.id)

  end

  def pbEndScene
    @exiting = true
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    Kernel.pbClearText
    @viewport.dispose
  end
end
