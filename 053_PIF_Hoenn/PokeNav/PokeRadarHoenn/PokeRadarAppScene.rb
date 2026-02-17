# todo:
# When all pokemon in the route are seen, can "scan" for species
#  - spawns a pokemon of that species nearby with notice behavior to flee
class PokeRadarAppScene < PokeNavAppScene
  INFO_TEXT_Y = 270

  def header_name
    return _INTL("PokeRadar")
  end

  def cursor_path
    return "Graphics/Pictures/Pokeradar/icon_button"
  end

  def header_path
    return "Graphics/Pictures/Pokeradar/bg_header"
  end

  def display_mode
    return :GRID
  end

  def x_gap
    return 75;
  end

  def y_gap
    return 50;
  end

  def columns
    return 8
  end

  def visible_rows
    return 3
  end

  def start_x
    return 40;
  end

  def start_y
    return 80;
  end

  def pbStartScene(main_menu_scene)
    @pokenav_main_menu_scene = main_menu_scene
    echoln 'START'
    if $PokemonTemp.pokeradar
      buttons = showCurrentScanningTarget
      super(buttons)
    else
      buttons = showWildPokemonList
      super(buttons)
      hover(@buttons[0]&.id)
    end
    showBattery
    showAreaName
  end

  def showWildPokemonList
    @encounter_type = $PokemonEncounters.encounter_type
    @unseenPokemon = listPokemonInCurrentRoute(@encounter_type, false, true)
    @seenPokemon = listPokemonInCurrentRoute(@encounter_type, true, false)
    echoln @unseenPokemon
    buttons = []
    @seenPokemon.each do |pokemon_species|
      echoln pokemon_species
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path, false)
      button = PokenavButton.new(pokemon_species, bmp, nil, nil
      )
      button.crop_width = button.source_bitmap.bitmap.width / 2
      buttons << button if button
    end
    @unseenPokemon.each do |pokemon_species|
      echoln pokemon_species
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path, true)
      button = PokenavButton.new(pokemon_species, bmp)
      button.crop_width = button.source_bitmap.bitmap.width / 2
      button.refresh
      buttons << button
    end
    return buttons
  end

  def createCursor
    return if $PokemonTemp.pokeradar
    super
  end
  def showCurrentScanningTarget
    echoln $PokemonTemp.pokeradar
    scanningPokemon = $PokemonTemp.pokeradar[0]
    icon_path = pbCheckPokemonIconFiles(scanningPokemon)
    bmp = load_bitmap(icon_path, false)
    button = PokenavButton.new(scanningPokemon, bmp)

    species_name = GameData::Species.get(scanningPokemon).real_name
    Kernel.pbDisplayText(_INTL("Currently scanning for {1}.", species_name), Graphics.width / 2, 200,500000)
    Kernel.pbDisplayText(_INTL("Current chain: {1}.", $PokemonTemp.pokeradar[2]), Graphics.width / 2, 230,500000)
    return [button]
  end

  def load_bitmap(path, dark = false)
    return nil unless path && path != ""
    bmp = Bitmap.new(path)

    if dark
      darken_bitmap(bmp, 220) # strength 0–255
    end

    return AnimatedBitmap.from_bitmap(bmp)
  end

  def darken_bitmap(bmp, amount)
    for x in 0...bmp.width
      for y in 0...bmp.height
        pixel = bmp.get_pixel(x, y)
        next if pixel.alpha == 0

        factor = (255 - amount) / 255.0
        r = (pixel.red * factor).to_i
        g = (pixel.green * factor).to_i
        b = (pixel.blue * factor).to_i

        bmp.set_pixel(x, y, Color.new(r, g, b, pixel.alpha))
      end
    end
  end

  #[rareness, species, minLevel, maxLevel]
  def get_encounter(species)
    for encounter in $PokemonEncounters.listPossibleEncounters(@encounter_type)
      if encounter[1] == species
        return encounter
      end
    end
    return nil
  end

  def get_energy_for_scan(species)
    encounter = get_encounter(species)
    rareness = encounter[0]

    energy = (100 - rareness) * 5
    (energy / 50.0).round * 50
  end

  def get_rarity_flavor_text(species)
    encounter = get_encounter(species)
    if encounter[1] == species
      rareness = encounter[0]
      if rareness < 5
        return _INTL("Very rare")
      elsif rareness < 10
        return _INTL("Rare")
      elsif rareness < 25
        return _INTL("Uncommon")
      elsif rareness < 40
        return _INTL("Common")
      else
        return _INTL("Very Common")
      end
    end

    return ""
  end

  def click(button_id)
    species = button_id
    if $PokemonTemp.pokeradar
      click_stop_scan(species)
    else
      if @seenPokemon.include?(species)
        click_seen(species)
      else
        click_unseen
      end

    end
    super
  end

  def hover(button_id)
    return if $PokemonTemp.pokeradar
    if @seenPokemon.include?(button_id)
      hover_seen(button_id)
    else
      hover_unseen
    end
    super
  end

  def click_stop_scan(species)
    species_name = GameData::Species.get(species).name
    options = []
    cmd_stop_scan = _INTL("Stop Scanning")
    cmd_cancel = _INTL("Cancel")
    options << cmd_stop_scan
    options << cmd_cancel
    chosen = pbMessage(_INTL("You are currently scanning for {1}.", species_name), options, options.length)
    case options[chosen]
    when cmd_stop_scan
      $PokemonTemp.pokeradar = nil
      pbEndScene
      pbStartScene(@pokenav_main_menu_scene)
    else
      return
    end

  end

  def click_seen(species)
    options = []
    cmd_scan = _INTL("Scan")
    cmd_cancel = _INTL("Cancel")
    options << cmd_scan
    options << cmd_cancel
    chosen = pbMessage(_INTL("What would you like to do?"), options, options.length)
    case options[chosen]
    when cmd_scan
      energy_needed = get_energy_for_scan(species)
      if true # Settings::POKERADAR_BATTERY_STEPS - $PokemonGlobal.pokeradarBattery >= energy_needed
        $PokemonGlobal.pokeradarBattery += energy_needed
        displayTextElements
        @exiting = true

        pbEndScene
        @pokenav_main_menu_scene.exiting = true
        @pokenav_main_menu_scene.pbEndScene

        encounter = get_encounter(species)
        min_level = encounter[2]
        max_level = encounter[3]
        level = rand(min_level..max_level)
        pbWait(16)
        pbMessage(_INTL("Scanning for {1}...\\wtnp[5]", GameData::Species.get(species).real_name))
        position = getTerrainTilesNearPlayer(getTerrainType, 3).sample
        if position
          echoln species
          set_pokeradar_data(species, level, position)
          spawn_pokeradar_pokemon(species, level)
        else
          pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
        end
      else
        pbMessage(_INTL("The battery is not charged enough for this scan!"))
      end
    else
      return
    end
  end

  # Reusing the old pokeradar mechanics for chaining
  def set_pokeradar_data(species, level, position)
    x = position[0]
    y = position[1]
    if $PokemonTemp.pokeradar && $PokemonTemp.pokeradar[2] > 0
      v = [(65536 / Settings::SHINY_POKEMON_CHANCE) - $PokemonTemp.pokeradar[2] * 200, 200].max
      v = 0xFFFF / v
      v = rand(65536) / v
      s = 2 if v == 0
    end
    pokeradar_grass = [x, y, 0, s]
    chain_count = 0
    $PokemonTemp.pokeradar = [0, 0, 0, []] if !$PokemonTemp.pokeradar
    $PokemonTemp.pokeradar[0] = species
    $PokemonTemp.pokeradar[1] = level
    $PokemonTemp.pokeradar[2] = chain_count
    $PokemonTemp.pokeradar[3] = pokeradar_grass if $PokemonTemp.pokeradar
  end

  def determine_shininess
    radar = $PokemonTemp.pokeradar
    return false if !radar || radar[2] <= 0
    chain_length = radar[2]
    base_shiny_threshold = 65536 / Settings::SHINY_POKEMON_CHANCE
    adjusted_threshold = base_shiny_threshold - chain_length * 200
    adjusted_threshold = [adjusted_threshold, 200].max

    shiny_roll_divisor = 0xFFFF / adjusted_threshold
    shiny_roll = rand(65536) / shiny_roll_divisor
    return shiny_roll == 0
  end

  def click_unseen
    pbMessage(_INTL('You need to encounter the Pokémon before you can scan for it.'))
  end

  def hover_seen(species)
    displayTextElements
    pokemon_name = GameData::Species.get(species).real_name
    Kernel.pbDisplayText(pokemon_name, Graphics.width / 2, INFO_TEXT_Y, 99999)
    Kernel.pbDisplayText(get_rarity_flavor_text(species), Graphics.width / 2, INFO_TEXT_Y + 30, 99999)
    Kernel.pbDisplayText(_INTL("Battery for scan: {1}", get_energy_for_scan(species)), Graphics.width / 2, INFO_TEXT_Y + 60, 99999)
  end

  def hover_unseen()
    displayTextElements
    echoln "hover unseen"
    pokemon_name = _INTL("Unknown Pokémon")
    Kernel.pbDisplayText(pokemon_name, Graphics.width / 2, INFO_TEXT_Y, 999999)
  end

  def displayTextElements
    super
    showBattery
    showAreaName

  end

  def showBattery
    $PokemonGlobal.pokeradarBattery = Settings::POKERADAR_BATTERY_STEPS unless $PokemonGlobal.pokeradarBattery
    battery_power = Settings::POKERADAR_BATTERY_STEPS - $PokemonGlobal.pokeradarBattery
    Kernel.pbDisplayText(_INTL("{1}/1000", battery_power), 450, HEADER_HEIGHT)
  end

  def showAreaName
    map_name = Kernel.getMapName($game_map.map_id)
    Kernel.pbDisplayText(_INTL("{1} ({2})", map_name, get_encounter_type_name), Graphics.width / 2, 40)
  end

  def get_encounter_type_name
    encounter_type = $PokemonEncounters.encounter_type
    case encounter_type
    when :Land
      return _INTL("Grass")
    when :Land1
      return _INTL("Clovers")
    when :Land2
      return _INTL("Dry Grass")
    when :Land3
      return _INTL("Flowers")
    when :LandMorning
      return _INTL("Grass (Morning)")
    when :LandDay
      return _INTL("Grass (Daytime)")
    when :LandNight
      return _INTL("Grass (Nighttime)")
    when :TallGrass
      return _INTL("Tall Grass")
    else
      return encounter_type.to_s
    end
  end

end

def getTerrainType
  encounter_type = $PokemonEncounters.encounter_type
  case encounter_type
  when :Land, :Land1, :Land2, :Land3, :LandMorning, :LandDay, :LandNight, :TallGrass
    return :Grass
  else
    return encounter_type
  end
end

def spawn_pokeradar_pokemon(species, level)
  return unless species && level
  pbWait(20)
  playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, $game_player.x, $game_player.y)
  pbWait(10)
  spawned_events = spawn_ow_pokemon(species, level, 1, 4)
  echoln "spawned events: #{spawned_events}"
  if spawned_events && spawned_events.length > 0
    event = spawned_events[0]
    event.behavior_roaming = :look_around
    # event.behavior_noticed = :flee
    event.direction = $game_player.direction
    playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, event.x, event.y)
  else
    pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
  end
end