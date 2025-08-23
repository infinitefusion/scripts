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


def secretBaseQuest_pickedNearbySpot()
  return false if !$Trainer.secretBase
  expected_map = 65
  expected_positions = [
    [30,43],[31,43],[32,42],[33,42],[34,42],[35,42],[36,40],[37,40],#trees
    [41,40] #cliff
  ]

  picked_base_map =  $Trainer.secretBase.outside_map_id
  picked_position = $Trainer.secretBase.outside_entrance_position

  echoln picked_base_map
  echoln picked_position
  echoln picked_base_map == expected_map && expected_positions.include?(picked_position)
  return picked_base_map == expected_map && expected_positions.include?(picked_position)
end