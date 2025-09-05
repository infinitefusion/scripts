class PokemonStorageScene
  attr_reader :cursormode
  attr_reader :screen

  alias _storageMultiselect_pbStartBox pbStartBox
  def pbStartBox(*args)
    _storageMultiselect_pbStartBox(*args)
    @cursormode = "default"
    @sprites["selectionrect"] = BitmapSprite.new(Graphics.width, Graphics.height, @arrowviewport)
    @sprites["selectionrect"].visible = false
  end


  def pbChangeSelection(key, selection)
    case key
    when Input::UP
      if @screen.multiSelectRange
        selection -= PokemonBox::BOX_WIDTH
        selection += PokemonBox::BOX_SIZE if selection < 0
      elsif selection == -1 # Box name
        selection = -2
      elsif selection == -2 # Party
        selection = PokemonBox::BOX_SIZE - 1 - PokemonBox::BOX_WIDTH * 2 / 3 # 25
      elsif selection == -3 # Close Box
        selection = PokemonBox::BOX_SIZE - PokemonBox::BOX_WIDTH / 3 # 28
      else
        selection -= PokemonBox::BOX_WIDTH
        selection = -1 if selection < 0
      end
    when Input::DOWN
      if @screen.multiSelectRange
        selection += PokemonBox::BOX_WIDTH
        selection -= PokemonBox::BOX_SIZE if selection >= PokemonBox::BOX_SIZE
      elsif selection == -1 # Box name
        selection = PokemonBox::BOX_WIDTH / 3 # 2
      elsif selection == -2 # Party
        selection = -1
      elsif selection == -3 # Close Box
        selection = -1
      else
        selection += PokemonBox::BOX_WIDTH
        if selection >= PokemonBox::BOX_SIZE
          if selection < PokemonBox::BOX_SIZE + PokemonBox::BOX_WIDTH / 2
            selection = -2 # Party
          else
            selection = -3 # Close Box
          end
        end
      end
    when Input::LEFT
      if @screen.multiSelectRange
        if (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
          selection += PokemonBox::BOX_WIDTH - 1
        else
          selection -= 1
        end
      elsif selection == -1 # Box name
        selection = -4 # Move to previous box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
        selection += PokemonBox::BOX_WIDTH - 1
      else
        selection -= 1
      end
    when Input::RIGHT
      if @screen.multiSelectRange
        if (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
          selection -= PokemonBox::BOX_WIDTH - 1
        else
          selection += 1
        end
      elsif selection == -1 # Box name
        selection = -5 # Move to next box
      elsif selection == -2
        selection = -3
      elsif selection == -3
        selection = -2
      elsif (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
        selection -= PokemonBox::BOX_WIDTH - 1
      else
        selection += 1
      end
    end
    return selection
  end

  def pbPartyChangeSelection(key, selection)
    maxIndex = @screen.multiSelectRange ? Settings::MAX_PARTY_SIZE - 1 : Settings::MAX_PARTY_SIZE
    case key
    when Input::LEFT
      selection -= 1
      selection = maxIndex if selection < 0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection > maxIndex
    when Input::UP
      if selection == Settings::MAX_PARTY_SIZE
        selection = Settings::MAX_PARTY_SIZE - 1
      else
        selection -= 2
        selection = selection % Settings::MAX_PARTY_SIZE if @screen.multiSelectRange
        selection = maxIndex if selection < 0
      end
    when Input::DOWN
      if selection == Settings::MAX_PARTY_SIZE
        selection = 0
      else
        selection += 2
        selection = selection % Settings::MAX_PARTY_SIZE if @screen.multiSelectRange
        selection = maxIndex if selection > maxIndex
      end
    end
    return selection
  end

  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key >= 0
        pbPlayCursorSE
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        if selection == -4
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection == -5
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection == -4 || selection == -5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(@storage.currentBox, selection)
        end
      end
      self.update
      if Input.trigger?(Input::JUMPUP)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::JUMPDOWN)
        pbPlayCursorSE
        nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::SPECIAL) # Jump to box name
        if selection != -1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0 # Organize only
        pbPlayDecisionSE
        pbNextCursorMode
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == -1 # Box name
          return [-4, -1]
        elsif selection == -2 # Party Pokémon
          return [-2, -1]
        elsif selection == -3 # Close Box
          return [-3, -1]
        end
      end
    end
  end

  def pbNextCursorMode()
    case @cursormode
    when "default"
      pbSetCursorMode("quickswap")
    when "quickswap"
      pbSetCursorMode((@screen.pbHolding?) ? "default" : "multiselect")
    when "multiselect"
      pbSetCursorMode("default") if !@screen.pbHolding?
    end
  end

  def pbSetCursorMode(value)
    @cursormode = value
    @sprites["arrow"].cursormode = value
    if @screen.multiSelectRange
      @screen.multiSelectRange = nil
      pbUpdateSelectionRect(@choseFromParty ? -1 : @storage.currentBox, 0)
    end
  end

  def pbSetHeldPokemon(pokemon)
    pokesprite = PokemonBoxIcon.new(pokemon, @arrowviewport)
    @sprites["arrow"].grabImmediate(pokesprite)
  end

  def pbUpdateSelectionRect(box, selected)
    if !@screen.multiSelectRange
      @sprites["selectionrect"].visible = false
      return
    end

    displayRect = Rect.new(0, 0, 1, 1)

    if box == -1
      xvalues = [] # [18, 90, 18, 90, 18, 90]
      yvalues = [] # [2, 18, 66, 82, 130, 146]
      for i in 0...Settings::MAX_PARTY_SIZE
        xvalues.push(@sprites["boxparty"].x + 18 + 72 * (i % 2))
        yvalues.push(@sprites["boxparty"].y + 2 + 16 * (i % 2) + 64 * (i / 2))
      end
      indexes = @screen.getMultiSelection(box, selected)
      minx = xvalues[indexes[0]]
      miny = yvalues[indexes[0]] + 16
      maxx = xvalues[indexes[indexes.length-1]] + 72 - 8
      maxy = yvalues[indexes[indexes.length-1]] + 64
      displayRect.set(minx, miny, maxx-minx, maxy-miny)
    else
      indexRect = @screen.getSelectionRect(box, selected)
      displayRect.x = @sprites["box"].x + 10 + (48 * indexRect.x)
      displayRect.y = @sprites["box"].y + 30 + (48 * indexRect.y) + 16
      displayRect.width = indexRect.width * 48 + 16
      displayRect.height = indexRect.height * 48
    end

    @sprites["selectionrect"].bitmap.clear
    @sprites["selectionrect"].bitmap.fill_rect(displayRect.x, displayRect.y, displayRect.width, displayRect.height, Color.new(0, 255, 0, 100))
    @sprites["selectionrect"].visible = true
  end

  def pbHoldMulti(box, selected, selectedIndex)
    pbSEPlay("GUI storage pick up")
    if box == -1
      @sprites["boxparty"].grabPokemonMulti(selected, selectedIndex, @sprites["arrow"])
    else
      @sprites["box"].grabPokemonMulti(selected, selectedIndex, @sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbPlaceMulti(box, index)
    pbSEPlay("GUI storage put down")
    heldpokesprites = @sprites["arrow"].multiHeldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if box == -1
      @sprites["boxparty"].placePokemonMulti(index, heldpokesprites)
    else
      @sprites["box"].placePokemonMulti(index, heldpokesprites)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = index
  end

  def pbReleaseMulti(box, selected)
    releaseSprites = []
    for index in selected
      sprite = nil
      if box == -1
        sprite = @sprites["boxparty"].getPokemon(index)
      else
        sprite = @sprites["box"].getPokemon(index)
      end
      releaseSprites.push(sprite) if sprite
    end
    if releaseSprites.length > 0
      for sprite in releaseSprites
        sprite.release
      end
      while releaseSprites[0].releasing?
        Graphics.update
        for sprite in releaseSprites
          sprite.update
        end
        self.update
      end
    end
  end

end
