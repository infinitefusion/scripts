class MultiSelectOptionsScene
  attr_reader :selected_items
  attr_reader :canceled

  #TODO: Preselected items don't appear as selected
  def initialize(items, preselected = [], title = "Select options",
                 item_name_proc = nil, filter_placeholder = "Shift to search",
                 item_weight_proc = nil)
    @items = items
    @item_name_proc = item_name_proc || proc { |item| item.to_s }
    @item_weight_proc = item_weight_proc || proc { |_item| 1 }
    @selected_items = preselected.dup
    echoln "PRESELECTED"
    echoln preselected

    @title_text = title
    @filter_placeholder = filter_placeholder
    @canceled = false
  end

  def pbStartScene(window_x = 0, window_y = 0)
    title_height  = 60
    filter_height = 60

    left_width  = Graphics.width / 2
    right_x     = window_x + left_width
    right_width = Graphics.width - left_width

    reference_text = @items.map { |i| @item_name_proc.call(i) }.max_by(&:length) || @filter_placeholder
    reference_text = @filter_placeholder if @filter_placeholder.length > reference_text.length

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites = {}
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL(@title_text), window_x, window_y, Graphics.width, title_height, @viewport)

    @sprites["filter"] = Window_UnformattedTextPokemon.newWithSize(
      reference_text, window_x, window_y + title_height, left_width, filter_height, @viewport)
    @sprites["filter"].setTextToFit(reference_text)

    @sprites["option"] = Window_MultiSelectFilterList.new(
      [], window_x, window_y + title_height + filter_height,
      left_width, Graphics.height - (window_y + title_height + filter_height),
      @viewport
    )
    @sprites["option"].active = true
    pbSetSystemFont(@sprites["option"].contents)

    @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/selarrow")
    @sprites["cursor"].z = 99999

    # Right-side panel: selected items + running total
    @sprites["selected_title"] = Window_UnformattedTextPokemon.newWithSize(
      "", right_x, window_y + title_height, right_width, filter_height, @viewport)

    @sprites["selected_list"] = Window_ReadOnlyList.new(
      [], right_x, window_y + title_height + filter_height,
      right_width, Graphics.height - (window_y + title_height + filter_height),
      @viewport
    )

    @filterText    = ""
    @filteredItems = []
    refreshList
  end

  CURSOR_X_OFFSET = -4

  def updateCursorPosition
    win = @sprites["option"]
    rect = win.itemRect(win.index)
    return if rect.width == 0 && rect.height == 0 # index out of visible range

    arrow_height = @sprites["cursor"].bitmap ? @sprites["cursor"].bitmap.height : 0
    y_center_offset = (win.rowHeight - arrow_height) / 2

    @sprites["cursor"].x = win.x + win.startX + rect.x + CURSOR_X_OFFSET
    @sprites["cursor"].y = win.y + win.startY + rect.y + y_center_offset
    @sprites["cursor"].visible = true
  end

  def cancelIndex
    return 0
  end

  def selectAllIndex
    return 1
  end

  def confirmIndex
    return 2
  end

  def itemStartIndex
    return 3
  end

  def refreshList
    filtered = @filterText.empty? ? @items.dup : @items.select { |i|
      @item_name_proc.call(i).downcase.include?(@filterText.downcase)
    }
    @filteredItems = filtered

    display = []
    flags   = []

    display.push(_INTL("Cancel"))
    flags.push(false)

    all_selected = filtered.length > 0 && filtered.all? { |i| @selected_items.include?(i) }
    display.push(all_selected ? _INTL("Unselect All") : _INTL("Select All"))
    flags.push(false)

    display.push(_INTL("Confirm"))
    flags.push(false)

    filtered.each do |i|
      display.push(@item_name_proc.call(i))
      flags.push(@selected_items.include?(i))
    end

    old_index = @sprites["option"].index || 0
    @sprites["option"].commands = display
    @sprites["option"].selected_flags = flags
    @sprites["option"].confirm_index = confirmIndex
    @sprites["option"].selall_index = selectAllIndex
    @sprites["option"].cancel_index = cancelIndex
    @sprites["option"].index = [old_index, display.length - 1].min
    @sprites["option"].refresh

    @sprites["filter"].text = @filterText.empty? ? @filter_placeholder : @filterText
    updateCursorPosition
    refreshSelectedPanel

    echoln @selected_items
  end

  def refreshSelectedPanel
    total_weight = @selected_items.sum { |i| @item_weight_proc.call(i) }
    @sprites["selected_title"].text = _INTL("{1} possible sprites", total_weight)
    lines = @selected_items.reverse.map { |i| @item_name_proc.call(i) }
    lines = [_INTL("")] if lines.empty?
    @sprites["selected_list"].commands = lines
    @sprites["selected_list"].refresh
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbOptions
    loop do
      Graphics.update
      Input.update
      old_index = @sprites["option"].index
      @sprites["option"].update
      updateCursorPosition if @sprites["option"].index != old_index

      if Input.trigger?(Input::ACTION)
        pbStartSearchEntry
        next
      end

      if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
        scrollToConfirm
        next
      end

      if Input.trigger?(Input::BACK)
        @canceled = true
        break
      elsif Input.trigger?(Input::USE)
        index = @sprites["option"].index

        if index == cancelIndex
          @canceled = true
          break
        elsif index == selectAllIndex
          all_selected = @filteredItems.length > 0 && @filteredItems.all? { |i| @selected_items.include?(i) }
          if all_selected
            @selected_items -= @filteredItems
          else
            @filteredItems.each do |item|
              @selected_items << item unless @selected_items.include?(item)
            end
          end
          pbSEPlay("GUI naming confirm")
          refreshList
        elsif index == confirmIndex
          break
        else
          item = @filteredItems[index - itemStartIndex]
          if @selected_items.include?(item)
            @selected_items.delete(item)
          else
            @selected_items << item
          end
          pbSEPlay("GUI naming confirm")
          refreshList
        end
      end
    end
  end

  def scrollToConfirm
    @sprites["option"].index = confirmIndex
    updateCursorPosition
  end

  def pbStartSearchEntry
    if $PokemonSystem.textinput == 1 # keyboard
      scene = PokedexTextEntry.new
    else
      scene = PokemonEntryScene2.new
    end
    scene.pbStartScene(
      _INTL("Search:"),
      0,  # min length (0 allows clearing the filter)
      30, # max length
      @filterText
    )
    query = scene.pbEntry
    scene.pbEndScene

    if query
      @filterText = query
      refreshList
    end
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class MultiSelectOptionScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(window_x = 0, window_y = 0)
    @scene.pbStartScene(window_x, window_y)
    @scene.pbOptions
    @scene.pbEndScene
    return nil if @scene.canceled
    return @scene.selected_items
  end
end

class Window_MultiSelectFilterList < Window_DrawableCommand
  attr_accessor :commands
  attr_accessor :selected_flags
  attr_accessor :confirm_index
  attr_accessor :selall_index
  attr_accessor :cancel_index

  def initialize(commands, x, y, width, height, viewport = nil)
    @commands = commands
    @selected_flags = []
    @confirm_index = nil
    @cancel_index = nil
    @selall_index = nil
    @selBaseColor     = Color.new(48, 96, 216)
    @selShadowColor   = Color.new(32, 32, 32)
    @confirmBaseColor   = Color.new(64, 200, 96)
    @confirmShadowColor = Color.new(24, 96, 40)
    @cancelBaseColor   = Color.new(216, 64, 64)
    @cancelShadowColor = Color.new(96, 24, 24)
    super(x, y, width, height, viewport)
  end

  def itemCount
    return @commands.length
  end

  def drawCursor(index, rect)
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    text = @commands[index]

    if index == @confirm_index
      base, shadow = @confirmBaseColor, @confirmShadowColor
    elsif index == @selall_index
      base, shadow = @selBaseColor, @selShadowColor
    elsif index == @cancel_index
      base, shadow = @cancelBaseColor, @cancelShadowColor
    elsif @selected_flags[index]
      base, shadow = @selBaseColor, @selShadowColor
    else
      base, shadow = self.baseColor, self.shadowColor
    end

    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, text, base, shadow)
  end

  def refresh
    self.contents.clear if self.contents
    super
  end
end

# Used for the "Selected" panel.
class Window_ReadOnlyList < Window_DrawableCommand
  attr_accessor :commands

  def initialize(commands, x, y, width, height, viewport = nil)
    @commands = commands
    super(x, y, width, height, viewport)
    self.active = false
  end

  def itemCount
    return @commands.length
  end

  def drawCursor(index, rect)
    return Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height,
                     @commands[index], self.baseColor, self.shadowColor)
  end

  def refresh
    self.contents.clear if self.contents
    super
  end
end