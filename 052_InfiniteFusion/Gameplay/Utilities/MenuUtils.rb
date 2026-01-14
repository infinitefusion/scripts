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