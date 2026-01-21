def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!", $Trainer.name, badgeName))
end

def pbReceiveMoney(amount)
  msgwindow = pbCreateMessageWindow(nil)
  goldwindow = pbDisplayGoldWindow(msgwindow)
  #show current money
  15.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end

  oldMoney    = $Trainer.money
  targetMoney = oldMoney + amount
  $Trainer.money = targetMoney
  step = [amount / 15, 1].max
  current = oldMoney

  #count up
  while current < targetMoney
    current += step
    current = targetMoney if current > targetMoney
    goldwindow.text = _INTL(
      "Money:\n<ar>{1}</ar>\n<ar><c3=00FF00>+ {2}</c3></ar>",
      current.to_s_formatted,
      amount.to_s_formatted
    )
    pbSEPlay("Mart buy item") if current < targetMoney
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end


  goldwindow.text = _INTL(
    "Money:\n<ar>{1}</ar>",
    targetMoney.to_s_formatted
  )

  #show final money
  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.width = 160 if goldwindow.width <= 160
  20.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    msgwindow.update
    goldwindow.update
  end
  goldwindow.dispose
  pbDisposeMessageWindow(msgwindow)
end



def promptCaughtPokemonAction(pokemon)
  pickedOption = false
  return pbStorePokemon(pokemon) if !$Trainer.party_full?
  return promptKeepOrRelease(pokemon) if isOnPinkanIsland() && !$game_switches[SWITCH_PINKAN_FINISHED]
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Add to your party"), _INTL("Store to PC"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapCaughtPokemon(pokemon)
        echoln pickedOption
        pickedOption = true
      end
    else
      # STORE
      pbStorePokemon(pokemon)
      echoln pickedOption
      pickedOption = true
    end
  end

end

def promptKeepOrRelease(pokemon)
  pickedOption = false
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Release a party member"), _INTL("Release this #{pokemon.name}"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapReleaseCaughtPokemon(pokemon)
        pickedOption = true
      end
    else
      pickedOption = true
    end
  end
end

# def pbChoosePokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false)
def swapCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  $PokemonStorage.pbStoreCaught($Trainer.party[index])
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def swapReleaseCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  releasedPokemon = $Trainer.party[index]
  pbMessage(_INTL("{1} was released.",releasedPokemon.name))
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def select_any_pokemon()
  commands = []
  for dex_num in 1..NB_POKEMON
    species = getPokemon(dex_num)
    commands.push([dex_num - 1, species.real_name, species.id])
  end
  return pbChooseList(commands, 0, nil, 1)
end



# chosen pokemon is returned with this format:
#[[boxID, boxPosition],pokemon]

def pbChoosePokemonPC(positionVariableNumber, pokemonVarNumber, ableProc = nil)
  chosen = nil
  pokemon = nil

    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.setFilter(ableProc) if ableProc
      chosen = screen.choosePokemon
      pokemon = $PokemonStorage[chosen[0]][chosen[1]] if chosen
      scene.pbCloseBox
    }
  pbSet(positionVariableNumber, chosen)
  pbSet(pokemonVarNumber, pokemon)
end

def set_player_birthday
  date = selectDate(_INTL("Your birthday is on"))
  $Trainer.birth_day = date.day
  $Trainer.birth_month = date.month
end

def selectDate(confirm_text = _INTL("You chose "))
  months_nb_days = {
    :JANUARY => 31,
    :FEBRUARY => 29,
    :MARCH => 31,
    :APRIL => 30,
    :MAY => 31,
    :JUNE => 30,
    :JULY => 31,
    :AUGUST => 31,
    :SEPTEMBER => 30,
    :OCTOBER => 31,
    :NOVEMBER => 30,
    :DECEMBER => 31,
  }
  month_names = {
    :JANUARY => _INTL("January"),
    :FEBRUARY => _INTL("February"),
    :MARCH => _INTL("March"),
    :APRIL => _INTL("April"),
    :MAY => _INTL("May"),
    :JUNE => _INTL("June"),
    :JULY => _INTL("July"),
    :AUGUST => _INTL("August"),
    :SEPTEMBER => _INTL("September"),
    :OCTOBER => _INTL("October"),
    :NOVEMBER => _INTL("November"),
    :DECEMBER => _INTL("December"),
  }

  pbMessage(_INTL("Which month?"))
  selected = false
  while !selected
    chosen_month_index = optionsMenu(month_names.values)
    month = month_names.keys[chosen_month_index]
    nb_days = months_nb_days[month]

    numberParams = ChooseNumberParams.new
    numberParams.setRange(1,nb_days)
    numberParams.setDefaultValue(1)
    chosen_day = pbMessageChooseNumber(_INTL("Which day?"),numberParams)

    chosen_month_name = month_names[month]
    if pbConfirmMessage(_INTL("{1} \\C[1]{2} {3}\\C[0]. Is that correct?",confirm_text, chosen_month_name,chosen_day))
      birthday = Time.new(2000,chosen_month_index+1,chosen_day)
      return birthday
    end
  end

end



def pbColor(color)
  # Mix your own colors: http://www.rapidtables.com/web/color/RGB_Color.htm
  return Color.new(0, 0, 0) if color == :BLACK
  return Color.new(255, 115, 115) if color == :LIGHTRED
  return Color.new(245, 11, 11) if color == :RED
  return Color.new(164, 3, 3) if color == :DARKRED
  return Color.new(47, 46, 46) if color == :DARKGREY
  return Color.new(47, 46, 46) if color == :DARKGREY
  return Color.new(100, 92, 92) if color == :LIGHTGREY
  return Color.new(226, 104, 250) if color == :PINK
  return Color.new(243, 154, 154) if color == :PINKTWO
  return Color.new(255, 160, 50) if color == :GOLD
  return Color.new(255, 186, 107) if color == :LIGHTORANGE
  return Color.new(95, 54, 6) if color == :BROWN
  return Color.new(122, 76, 24) if color == :LIGHTBROWN
  return Color.new(255, 246, 152) if color == :LIGHTYELLOW
  return Color.new(242, 222, 42) if color == :YELLOW
  return Color.new(80, 111, 6) if color == :DARKGREEN
  return Color.new(154, 216, 8) if color == :GREEN
  return Color.new(197, 252, 70) if color == :LIGHTGREEN
  return Color.new(74, 146, 91) if color == :FADEDGREEN
  return Color.new(6, 128, 92) if color == :DARKLIGHTBLUE
  return Color.new(18, 235, 170) if color == :LIGHTBLUE
  return Color.new(139, 247, 215) if color == :SUPERLIGHTBLUE
  return Color.new(35, 203, 255) if color == :BLUE
  return Color.new(3, 44, 114) if color == :DARKBLUE
  return Color.new(7, 3, 114) if color == :SUPERDARKBLUE
  return Color.new(63, 6, 121) if color == :DARKPURPLE
  return Color.new(113, 16, 209) if color == :PURPLE
  return Color.new(219, 183, 37) if color == :ORANGE
  return Color.new(255, 255, 255, 0) if color == :INVISIBLE
  return MessageConfig::LIGHT_TEXT_MAIN_COLOR if color == :LIGHT_TEXT_MAIN_COLOR
  return MessageConfig::LIGHT_TEXT_SHADOW_COLOR if color == :LIGHT_TEXT_SHADOW_COLOR
  return MessageConfig::DARK_TEXT_MAIN_COLOR if color == :DARK_TEXT_MAIN_COLOR
  return MessageConfig::DARK_TEXT_SHADOW_COLOR if color == :DARK_TEXT_SHADOW_COLOR
  return Color.new(255, 255, 255)
end