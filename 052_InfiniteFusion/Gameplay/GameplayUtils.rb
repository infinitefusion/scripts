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

def npcTrade(npcPokemon_species, nickname, trainerName, playerPokemonProc)
  chosen_pokemon = pbChoosePokemon(1, 2, playerPokemonProc)
  chosen_position = pbGet(1)
  return nil if chosen_position <= -1
  pbStartTrade(chosen_position, npcPokemon_species, nickname, trainerName, 0)
end

def floorHole(mapBelow, frames_for_fall=8, bikeOnly=true)
  return unless mapBelow
  return if $game_player.moving?

  event = this_event()
  event.instance_variable_set(:@idle_frames, 0) unless event.instance_variable_defined?(:@idle_frames)
  event.instance_variable_set(:@idle_frames, event.instance_variable_get(:@idle_frames) + 1)

  frames_for_fall = 0 if bikeOnly && !$PokemonGlobal.bicycle

  if event.instance_variable_get(:@idle_frames) >= frames_for_fall
    event.instance_variable_set(:@idle_frames, 0)

    # Find a passable landing tile on the target map
    target_x, target_y = findPassableLanding(mapBelow, $game_player.x, $game_player.y)
    return unless target_x

    pbSEPlay("Slash")
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y)
    event.direction_fix = false
    event.turn_left

    pbWait(4)
    pbFadeOutIn {
      $game_temp.player_new_map_id = mapBelow
      $game_temp.player_new_x = target_x
      $game_temp.player_new_y = target_y
      pbCancelVehicles
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbWait(8)
  end
end

# Loads the target map and spirals outward from (start_x, start_y)
# until a passable tile is found. Returns [x, y] or [nil, nil].
def findPassableLanding(map_id, start_x, start_y, max_radius=10)
  # Load the target map data without switching to it
  map_data = load_data(sprintf("Data/Map%03d.rxdata", map_id))
  target_map = Game_Map.new
  target_map.setup(map_id)

  # Check exact position first
  if target_map.passableStrict?(start_x, start_y, 2)
    return [start_x, start_y]
  end

  # Spiral outward: check ring by ring
  1.upto(max_radius) do |radius|
    (-radius..radius).each do |dx|
      (-radius..radius).each do |dy|
        next unless dx.abs == radius || dy.abs == radius  # Only check the outer ring
        x = start_x + dx
        y = start_y + dy
        next unless target_map.valid?(x, y)
        return [x, y] if target_map.passableStrict?(x, y, 2)
      end
    end
  end

  return [nil, nil]
end

BASIC_SHIRTS = {
:GRASS => "basicgrass",
:FIRE => "basicfire",
:WATER => "basicwater",
:BUG => "basicbug",
:NORMAL => "basicnormal",
:ROCK => "basicrock",
:GROUND => "basicground",
:STEEL => "basicsteel",
:PSYCHIC => "basicpsychic",
:POISON => "basicpoison",
:ICE => "basicice",
:GHOST => "basicghost",
:FLYING => "basicflying",
:FIGHTING => "basicfight",
:FAIRY => "basicfairy",
:ELECTRIC => "basicelectric",
:DRAGON => "basicdragon",
:DARK => "basicdark",
}

def basicTypeShirts(event_id, nb_owned_for_reward = 5)
  GameData::Type.each do |type|
    nb_owned = 0
    GameData::Species.each do |species|
      if $Trainer.pokedex.owned?(species.species) && species.hasType?(type)
        nb_owned += 1
      end
    end
    if nb_owned >= nb_owned_for_reward
      clothes_reward = BASIC_SHIRTS[type.id]
      unless hasClothes?(clothes_reward)
        pbCallBub(2,event_id)
        pbMessage(_INTL("Let's see your Pokédex..."))
        pbCallBub(2,event_id)
        pbMessage(_INTL("Oh! You've caught {1} \\C[1]{2}-type\\C[0] Pokémon! You must be a huge {2} fan!",nb_owned,type.name))
        pbCallBub(2,event_id)
        pbMessage(_INTL("I have just the shirt for you. Here you go!"))
        obtainClothes(clothes_reward)
        return true
      end
    end
  end
  return false
end

def timeTrialStart
  $game_temp.time_trial_bumps =0
  pbSet(VAR_TIME_TRIAL_START,Time.now)
end

def timeTrialStop
  currentTime = Time.now
  startTime = pbGet(VAR_TIME_TRIAL_START)
  elapsed = (currentTime - startTime).to_f.truncate(3)
  pbSet(VAR_TIME_TRIAL_SECONDS, elapsed)
end

def timeTrialApplyBumpsPenalty
  nb_bumps = $game_temp.time_trial_bumps
  current_time = pbGet(VAR_TIME_TRIAL_SECONDS)
  current_time += (nb_bumps*0.5)
  pbSet(VAR_TIME_TRIAL_SECONDS, current_time.truncate(3))
end

def get_current_town_map_location
  map_data = pbLoadTownMapData
  all_maps = map_data[0][2]
  map_id_position= find_position_for_map(all_maps, $game_map.map_id)
  if map_id_position
    return $game_map.map_id
  else
    return $Trainer.last_visited_town_map_location
  end
end

