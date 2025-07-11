# available channels
# :RANDOM
# :NEWS
# :WEATHER

TV_CHANNELS = [:NEWS, :WEATHER]
def showTVText(channel = :RANDOM)
  channel = TV_CHANNELS.sample if channel == :RANDOM
  case channel
  when :NEWS
    pbMessage(getTVNewsCaption())
  when :WEATHER
    pbMessage(_INTL("It's the weather channel! Let's see how things are looking out today."))
    pbWeatherMapMap()
  end
end

SWITCH_REPORTER_AT_PETALBURG = 2026

def getTVNewsCaption()
  if $game_switches[SWITCH_REPORTER_AT_PETALBURG]
    return _INTL("It's showing the local news. There's a berry-growing contest going on in Petalburg Town!")
  else
    return _INTL("It’s a rerun of PokéChef Deluxe. Nothing important on the news right now.")
  end
end

def hoennSelectStarter
  starters = [obtainStarter(0), obtainStarter(1), obtainStarter(2)]
  selected_starter = StartersSelectionScene.new(starters).startScene
  pbAddPokemonSilent(selected_starter)
  return selected_starter
end
