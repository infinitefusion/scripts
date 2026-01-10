class GameplayOptionsScene < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Gameplay Options"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Gameplay options")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    @current_game_mode = getTrainersDataMode
    options = []



    options << EnumOption.new(_INTL("Default Movement"), [_INTL("Walking"), _INTL("Running")],
                              proc { $PokemonSystem.runstyle },
                              proc { |value| $PokemonSystem.runstyle = value },
                              [_INTL("Default to walking when not holding the Run key"),
                               _INTL("Default to running when not holding the Run key")]
    )

    if Settings::KANTO
      options << EnumOption.new(_INTL("Difficulty"), [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
                                proc { $Trainer.selected_difficulty },
                                proc { |value|
                                  setDifficulty(value)
                                  @manually_changed_difficulty = true
                                }, [_INTL("All Pokémon in the team gain experience. Otherwise the same as Normal difficulty."),
                                    _INTL("The default experience. Levels are similar to the official games."),
                                    _INTL("Higher levels and smarter AI. All trainers have access to healing items.")]
      )
    end

    if Settings::HOENN
      options << EnumOption.new(_INTL("Overworld Encounters"), [_INTL("On"), _INTL("Off")],
                                proc { $PokemonSystem.overworld_encounters ? 0 : 1 },
                                proc { |value| $PokemonSystem.overworld_encounters = value == 0 },
                                [_INTL("Pokémon are encountered in the overworld."),
                                 _INTL("Pokémon are only encountered in tall grass, etc.")]
      )
    end

    if $game_switches && ($game_switches[SWITCH_NEW_GAME_PLUS] || $game_switches[SWITCH_BEAT_THE_LEAGUE]) # beat the league
      options <<
        EnumOption.new(_INTL("Battle type"), [_INTL("1v1"), _INTL("2v2"), _INTL("3v3")],
                       proc { $PokemonSystem.battle_type },
                       proc { |value|
                         if value == 0
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         elsif value == 1
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [2, 2]
                         elsif value == 2
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [3, 3]
                         else
                           $game_variables[VAR_DEFAULT_BATTLE_TYPE] = [1, 1]
                         end
                         $PokemonSystem.battle_type = value
                       }, _INTL("Sets the number of Pokémon sent out in battles (when possible)")
        )
    end

    options << EnumOption.new(_INTL("Speed-up type"), [_INTL("Hold"), _INTL("Toggle")],
                              proc { $PokemonSystem.speedup },
                              proc { |value|
                                $PokemonSystem.speedup = value
                              }, _INTL("Pick how you want speed-up to be enabled")
    )

    options << SliderOption.new(_INTL("Speed-up speed"), 1, 10, 1,
                                proc { $PokemonSystem.speedup_speed },
                                proc { |value|
                                  $PokemonSystem.speedup_speed = value
                                }, _INTL("Sets by how much to speed up the game when holding the speed up button (Default: 3x)")
    )

    options << EnumOption.new(_INTL("Quick Surf"), [_INTL("Off"), _INTL("On")],
                              proc { $PokemonSystem.quicksurf },
                              proc { |value| $PokemonSystem.quicksurf = value },
                              _INTL("Start surfing automatically when interacting with water")
    )

    if $game_switches && $game_switches[SWITCH_LEGENDARY_MODE]
      selected_game_mode = $game_switches[SWITCH_MODERN_MODE] ? 1 : 0
      options << EnumOption.new(_INTL("Trainers"), [_INTL("Classic"), _INTL("Remix")],
                                proc { selected_game_mode },
                                proc { |value|
                                  $game_switches[SWITCH_MODERN_MODE] = value == 1
                                  @manually_changed_gamemode = true
                                },
                                [_INTL("Use trainers from Classic Mode for Legendary Mode"),
                                 _INTL("Use trainers from Remix Mode for Legendary Mode")]
      )
    end
    return options
  end
end
