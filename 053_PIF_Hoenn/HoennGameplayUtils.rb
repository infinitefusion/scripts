# available channels
# :RANDOM
# :NEWS
# :WEATHER

TV_CHANNEL_CHANCES = {
  NEWS: 3,
  WEATHER: 3,
  TREND: 1
}

def showTVText(channel = :RANDOM)

  if channel == :RANDOM
    channel = select_random_channel
  end

  case channel
  when :NEWS
    pbTVNews()
  when :WEATHER
    pbMessage(_INTL("It's the weather channel! Let's see how things are looking out today."))
    pbWeatherMap()
  when :TREND
    getTVTrendMessages()
  end
end


SWITCH_REPORTER_AT_PETALBURG = 2026
SWITCH_REPORTER_PETALBURG_INTERVIEWED = 2027

VAR_REPORTER_Q1 = 1006
VAR_REPORTER_Q2 = 1007
VAR_REPORTER_Q3 = 1008
VAR_REPORTER_Q4 = 1009
VAR_REPORTER_Q5 = 1010

def select_random_channel
  available_channels = TV_CHANNEL_CHANCES.dup
  available_channels.delete(:TREND) unless pbGet(VAR_TRENDY_PHRASE).is_a?(String)

  channel_picks = []
  for channel in available_channels.keys
    channel = channel
    chances = TV_CHANNEL_CHANCES[channel]
    for i in 0..chances
      channel_picks << channel
    end
  end
  return channel_picks.sample
end



def getTVTrendMessages()
  current_phrase = pbGet(VAR_TRENDY_PHRASE)
  vowels =["A","E","I","O","U"]
  if vowels.include?(current_phrase[0])
    adverb = _INTL("an")
  else
    adverb = _INTL("a")
  end

  pbMessage(_INTL("It's the trend-watcher network channel!"))
  pbMessage(_INTL("\"Everybody's talking about it, #{current_phrase} has been all the rage all around the region!\""))
  pbMessage(_INTL("\"Nobody knows where it's started, but #{current_phrase} is all that the younger people are talking about these days\""))
  case rand(3)
  when 0
    pbMessage(_INTL("\"Where can someone get their hands on #{adverb} #{current_phrase}? We'll continue our investigation to find out!'\""))
  when 1
    pbMessage(_INTL("\"Experts say that #{current_phrase} may just be the next big thing! Stay tuned for updates!\""))
  when 2
    pbMessage(_INTL("\"Some say that #{current_phrase} just a fad, but others seem to think it's here to stay! Stay tuned for updates!\""))
  end
end

#       pbMessage(_INTL("\"\""))


def pbTVNews()
  if $game_switches[SWITCH_REPORTER_AT_PETALBURG]
    if $game_switches[SWITCH_REPORTER_PETALBURG_INTERVIEWED]
      pbMessage(_INTL("It's showing the local news. There's a berry-growing contest going on in Petalburg Town!"))
      berryContestTVNews
    end
  else
    return pbMessage(_INTL("It's a rerun of PokéChef Deluxe. Nothing important on the news right now."))
  end
end

#pbMessage(_INTL("\"\""))
def berryContestTVNews
  pbMessage(_INTL("\"...I'm currently standing in front of the berry-growing contest in Petalburg Town. We've interviewed {1}, a local trainer to get their thoughts on the contest!\"",$Trainer.name))

  second_part = "."
  case $game_variables[VAR_REPORTER_Q1]
  when 0 #First time in contest? Yes
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL(", but they seemed very confident about it!")
    when 1
      second_part = _INTL(", and they seemed to be having fun already!")
    when 2
      second_part = _INTL(", and they understandably seemed a bit nervous!")
    when 2
      second_part = _INTL(", but they didn't really seem very interested in it. Perhaps, they only joined for the prize?")
    end
    pbMessage(_INTL("\"This was {1}'s first time participating {2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"Apparently, their strategy to win is to {1}. We'll see how that pays off for them!\"",$game_variables[VAR_REPORTER_Q3].downcase))
  when 1 #First time in contest? No
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL("They seemed to be enjoying it a great amount!")
    when 1
      second_part = _INTL("It seemed they were still having a lot of fun!")
    when 2
      second_part = _INTL("The novelty wore down a bit for them, but they said they're still having a good time.")
    when 2
      second_part = _INTL("They didn't seem too interested in the contest when I asked them, but they still came back to participate again.")
    end
    pbMessage(_INTL("\"{1} is a returning participant to the contest. {2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"According to them, the secret trick to growing berries is to {1}... Who would've thought!'\"",$game_variables[VAR_REPORTER_Q3].downcase))

  when 2 #First time in contest? Not participating
    case $game_variables[VAR_REPORTER_Q2]
    when 0 #Really fun
      second_part = _INTL(", it almost seems like they were having even more fun than the contestants themselves.!")
    when 1
      second_part = _INTL(", but they said that it was still fun as a spectator.")
    when 2
      second_part = _INTL(", they just came to check it out of curiosity.")
    when 2
      second_part = _INTL(". They didn't seem too interested in the contest when I asked them, it seems they were just passing by.")
    end
    pbMessage(_INTL("\"{1} said they're not participating in the contest this year{2}\"",$Trainer.name,second_part))
    pbMessage(_INTL("\"I asked them to sum up the contest in one word and they said \"{1}\", without any hesitation! That really says it all, doesn't it?''\"",$game_variables[VAR_REPORTER_Q3]))
  end
  pbWait(10)
  pbMessage("\"This was Gabby, reporting live from Petalburg Town. We'll see you again on our next broadcast!\"")
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
    [30, 43], [31, 43], [32, 42], [33, 42], [34, 42], [35, 42], [36, 40], [37, 40], # trees
    [41, 40] # cliff
  ]

  picked_base_map = $Trainer.secretBase.outside_map_id
  picked_position = $Trainer.secretBase.outside_entrance_position

  echoln picked_base_map
  echoln picked_position
  echoln picked_base_map == expected_map && expected_positions.include?(picked_position)
  return picked_base_map == expected_map && expected_positions.include?(picked_position)
end

# To scroll a picture on screen in a seamless, continuous loop (used in the truck scene in the intro)
# Provide 2 pictures (so that the loop isn't choppy)
# Speed in pixels per frame
def scroll_picture_loop(pic_a_nb, pic_b_nb, width, speed)
  pic_a = $game_screen.pictures[pic_a_nb]
  pic_b = $game_screen.pictures[pic_b_nb]

  # move both
  pic_a.x -= speed
  pic_b.x -= speed

  # wrap-around: always place offscreen one after the other
  if pic_a.x <= -width
    pic_a.x = pic_b.x + width
  elsif pic_b.x <= -width
    pic_b.x = pic_a.x + width
  end
end

# Setup:
# Vendors placed in the map with a name that starts with "vendor"
# They need to have a self switch B to deactivate them on their last page
#
# Market spots placed in the map with the name "market_spot"

# When assign_market_vendors is called, the game assign a random
# vendor to each of the market spots and reset its switches.
# All of the others will be made invisible
#
def list_market_vendors()
  vendors = []
  $game_map.events.each do |id, event|
    vendors << id if event.name.start_with?("vendor")
  end
  return vendors
end

def list_market_spots()
  spots = []
  $game_map.events.each do |id, event|
    spots << id if event.name == "market_spot"
  end
  return spots
end

def reset_vendor_events(vendors_ids_list)
  vendors_ids_list.each do |id|
    pbSetSelfSwitch(id, "A", false)
    pbSetSelfSwitch(id, "B", true)
    event = $game_map.events[id]
    event.moveto(0, 0)
  end
end

def assign_market_vendors
  vendor_events = list_market_vendors
  reset_vendor_events(vendor_events)

  market_spots = list_market_spots

  chosen_vendors = vendor_events.sample(market_spots.size)
  chosen_vendors.shuffle
  assign_vendors_to_spots(chosen_vendors)

end

def assign_vendors_to_spots(vendors_ids)
  market_spots = list_market_spots
  market_spots.each do |spot_event_id|
    spot_event = $game_map.events[spot_event_id]
    coordinates = [spot_event.x, spot_event.y]
    direction = spot_event.direction

    assigned_vendor_id = vendors_ids[-1]
    vendors_ids.pop
    assigned_vendor_event = $game_map.events[assigned_vendor_id]
    assigned_vendor_event.moveto(coordinates.first, coordinates.last)
    #assigned_vendor_event.direction = direction
    pbSetSelfSwitch(assigned_vendor_id, "B", false)
  end
end

# Moves the assigned vendors to their spots
# Needs to be called evertime the map is reloaded
def reposition_market_vendors
  all_vendors = list_market_vendors
  active_vendors = []
  all_vendors.each do |vendor_id|
    unless pbGetSelfSwitch(vendor_id, "B")
      active_vendors << vendor_id
    end
  end
  active_vendors.shuffle
  assign_vendors_to_spots(active_vendors)
end

def map_is_altering_cave?
  return false unless Settings::HOENN
  return $game_map.map_id == 70
end

def select_altering_cave_encounter
  level_range = 8..16
  encounter_table =
    {
      :MONDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:HOUNDOUR],
      :TUESDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:SCRAGGY],
      :WEDNESDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:ZORUA],
      :THURSDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:WOOBAT],
      :FRIDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:TEDDIURSA],
      :SATURDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:TYNAMO],
      :SUNDAY => [:ZUBAT,:ZUBAT,:ZUBAT,:ZUBAT,:SMEARGLE],
    }
  day_of_week = getDayOfTheWeek
  species = encounter_table[day_of_week].sample
  level = rand(level_range)
  return [species, level]
end





