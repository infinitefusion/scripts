

class PokemonStorageScreen
  attr_accessor :multiheldpkmn
  attr_accessor :multiSelectRange

  alias _storageMultiSelect_initialize initialize

  def initialize(*args)
    _storageMultiSelect_initialize(*args)
    @multiheldpkmn = []
  end


  def pcOrganizeCommand()
    isTransferBox = @storage[@storage.currentBox].is_a?(StorageTransferBox)
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected == nil
        if pbHeldPokemon
          pbDisplay(_INTL("You're holding a Pokémon!"))
          next
        end
        if @multiSelectRange
          pbPlayCancelSE
          @multiSelectRange = nil
          @scene.pbUpdateSelectionRect(0, 0)
          next
        end
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0] == -3 # Close box
        if pbHeldPokemon
          pbDisplay(_INTL("You're holding a Pokémon!"))
          next
        end
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      elsif selected[0] == -4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0], selected[1]]
        heldpoke = pbHeldPokemon
        if @scene.cursormode == "multiselect"
          multiSelectAction(selected)
        elsif @scene.cursormode == "quickswap"
          quickSwap(selected, pokemon)
        elsif @fusionMode
          pbFusionCommands(selected)
        else
          organizeActions(selected, pokemon, heldpoke, isTransferBox)
        end
      end
    end
    @scene.pbCloseBox
  end

  def multiSelectAction(selected)
    echoln "okay?"
    echoln @scene.cursormode
    if @scene.cursormode == "multiselect"
      echoln pbMultiHeldPokemon
      if pbMultiHeldPokemon.length > 0
        pbPlaceMulti(selected[0], selected[1])
      elsif !@multiSelectRange
        pbPlayDecisionSE
        @multiSelectRange = [selected[1], nil]
        @scene.pbUpdateSelectionRect(selected[0], selected[1])
        return
      elsif !@multiSelectRange[1]
        @multiSelectRange[1] = selected[1]

        pokemonCount = 0
        noneggCount = 0
        for index in getMultiSelection(selected[0], nil)
          pokemonCount += 1 if @storage[selected[0], index]
          if @storage[selected[0], index]
            unless @storage[selected[0], index].egg?
              noneggCount += 1
            end
          end
        end

        if pokemonCount == 0
          pbPlayCancelSE
          @multiSelectRange = nil
          @scene.pbUpdateSelectionRect(selected[0], selected[1])
          return
        end

        commands = []
        cmdMove = -1
        cmdRelease = -1
        cmdCancel = -1
        cmdExport = -1
        cmdBattle = -1

        helptext = _INTL("Selected {1} Pokémon.", pokemonCount)

        commands[cmdMove = commands.length] = _INTL("Move")
        commands[cmdRelease = commands.length] = _INTL("Release")

        command = pbShowCommands(helptext, commands)

        if command == cmdMove
          pbHoldMulti(selected[0], selected[1])
        elsif command == cmdRelease
          pbReleaseMulti(selected[0])
        end
        @multiSelectRange = nil
        @scene.pbUpdateSelectionRect(selected[0], selected[1])
      end
    end
  end

  def pbReleaseMulti(box)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    ableCount = 0
    finalReleased = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      if pokemon.owner.name  == "RENTAL"
        pbDisplay(_INTL("This Pokémon cannot be released"))
        return
      elsif pokemon.egg?
        pbDisplay(_INTL("You can't release an Egg."))
        return false
      elsif pokemon.mail
        pbDisplay(_INTL("Please remove the mail."))
        return false
      end
      ableCount += 1 if pbAble?(pokemon)
      finalReleased.push(index)
    end
    if box == -1 && pbAbleCount == ableCount
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release {1} Pokémon?", finalReleased.length), [_INTL("No"), _INTL("Yes")])
    if command == 1
      commandConfirm = pbShowCommands(_INTL("The {1} Pokémon will be lost forever. Release them?", finalReleased.length), [_INTL("No"), _INTL("Yes")])
      if commandConfirm == 1
        @multiSelectRange = nil
        @scene.pbUpdateSelectionRect(0, 0)
        @scene.pbReleaseMulti(box, finalReleased)
        @storage.pbDeleteMulti(box, finalReleased)
        @scene.pbRefresh
        pbDisplay(_INTL("The Pokémon were released."))
        pbDisplay(_INTL("Bye-bye!"))
        @scene.pbRefresh
      end
    end
    return
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
      maxx = xvalues[indexes[indexes.length - 1]] + 72 - 8
      maxy = yvalues[indexes[indexes.length - 1]] + 64
      displayRect.set(minx, miny, maxx - minx, maxy - miny)
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

  def pbMultiHeldPokemon
    return @multiheldpkmn
  end

  def pbHolding?
    return @heldpkmn != nil || @multiheldpkmn.length > 0
  end

  def pbHoldMulti(box, selectedIndex)
    selected = getMultiSelection(box, nil)
    return if selected.length == 0
    selectedPos = getBoxPosition(box, selectedIndex)
    ableCount = 0
    newHeld = []
    finalSelected = []
    for index in selected
      pokemon = @storage[box, index]
      next if !pokemon
      ableCount += 1 if pbAble?(pokemon)
      pos = getBoxPosition(box, index)
      newHeld.push([pokemon, pos[0] - selectedPos[0], pos[1] - selectedPos[1]])
      finalSelected.push(index)
    end
    if box == -1 && pbAbleCount == ableCount
      if newHeld.length > 1
        # For convenience: if you selected every Pokémon in the party, deselect the first one
        for i in 0...newHeld.length
          if pbAble?(newHeld[i][0])
            newHeld.delete_at(i)
            finalSelected.delete_at(i)
            break
          end
        end
      else
        pbPlayBuzzerSE
        pbDisplay(_INTL("That's your last Pokémon!"))
        return
      end
    end
    @multiSelectRange = nil
    @scene.pbUpdateSelectionRect(0, 0)
    @scene.pbHoldMulti(box, finalSelected, selectedIndex)
    @multiheldpkmn = newHeld
    @storage.pbDeleteMulti(box, finalSelected)
    @scene.pbRefresh
  end



  def getSelectionRect(box, currentSelected)
    rangeEnd = (currentSelected != nil ? currentSelected : @multiSelectRange[1])

    if !@multiSelectRange || !@multiSelectRange[0] || !rangeEnd
      return nil
    end

    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH

    ax = @multiSelectRange[0] % boxWidth
    ay = (@multiSelectRange[0].to_f / boxWidth).floor
    bx = rangeEnd % boxWidth
    by = (rangeEnd.to_f / boxWidth).floor

    minx = [ax, bx].min
    miny = [ay, by].min
    maxx = [ax, bx].max
    maxy = [ay, by].max

    return Rect.new(minx, miny, maxx-minx+1, maxy-miny+1)
  end

  def getMultiSelection(box, currentSelected)
    rect = getSelectionRect(box, currentSelected)

    ret = []

    for j in (rect.y)..(rect.y+rect.height-1)
      for i in (rect.x)..(rect.x+rect.width-1)
        ret.push(getBoxIndex(box, i, j))
      end
    end

    return ret
  end

  def getBoxIndex(box, x, y)
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    return x + y * boxWidth
  end

  def getBoxPosition(box, index)
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    return index % boxWidth, (index.to_f / boxWidth).floor
  end

  def pbPlaceMulti(box, selectedIndex)
    selectedPos = getBoxPosition(box, selectedIndex)
    echoln selectedPos
    boxWidth = box == -1 ? 2 : PokemonBox::BOX_WIDTH
    boxHeight = box == -1 ? (Settings::MAX_PARTY_SIZE / 2).ceil : PokemonBox::BOX_HEIGHT
    if box >= 0
      for held in @multiheldpkmn
        heldX = held[1] + selectedPos[0]
        heldY = held[2] + selectedPos[1]
        if heldX < 0 || heldX >= PokemonBox::BOX_WIDTH || heldY < 0 || heldY >= PokemonBox::BOX_HEIGHT
          pbDisplay("Can't place that there.")
          return
        end
        if @storage[box, heldX + heldY * PokemonBox::BOX_WIDTH]
          pbDisplay("Can't place that there.")
          return
        end
      end
      @scene.pbPlaceMulti(box, selectedIndex)
      for held in @multiheldpkmn
        pokemon = held[0]
        heldX = held[1] + selectedPos[0]
        heldY = held[2] + selectedPos[1]
        pokemon.time_form_set = nil
        pokemon.form = 0 if pokemon.isSpecies?(:SHAYMIN)
        @storage[box, heldX + heldY * PokemonBox::BOX_WIDTH] = pokemon
      end
    else
      partyCount = @storage.party.length
      if partyCount + @multiheldpkmn.length > Settings::MAX_PARTY_SIZE
        pbDisplay("Can't place that there.")
        return
      end
      @scene.pbPlaceMulti(box, selectedIndex)
      for held in @multiheldpkmn
        pokemon = held[0]
        pokemon.time_form_set = nil
        pokemon.form = 0 if pokemon.isSpecies?(:SHAYMIN)
        pokemon.heal if !$game_temp.fromkurayshop
        @storage.party.push(pokemon)
      end
    end
    @scene.pbRefresh
    @multiheldpkmn = []
  end

end



