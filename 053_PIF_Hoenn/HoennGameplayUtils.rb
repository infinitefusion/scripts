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
    return _INTL("It's a rerun of PokéChef Deluxe. Nothing important on the news right now.")
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
    assigned_vendor_event.direction = direction
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

