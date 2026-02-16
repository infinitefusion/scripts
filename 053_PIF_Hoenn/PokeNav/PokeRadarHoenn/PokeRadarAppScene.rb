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
    @main_menu_scene = main_menu_scene
    echoln 'START'
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
    super(buttons)
    hover(@buttons[0]&.id)
    showBattery
    showAreaName
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
    if @seenPokemon.include?(species)
      click_seen(species)
    else
      click_unseen
    end
    super
  end

  def hover(button_id)
    if @seenPokemon.include?(button_id)
      hover_seen(button_id)
    else
      hover_unseen
    end
    super
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
      if Settings::POKERADAR_BATTERY_STEPS - $PokemonGlobal.pokeradarBattery >= energy_needed
        $PokemonGlobal.pokeradarBattery += energy_needed
        displayTextElements
        @exit = true
        pbMessage(_INTL("Scanning for {1}...", GameData::Species.get(species).real_name))

        encounter = get_encounter(species)
        min_level = encounter[2]
        max_level = encounter[3]
        level = rand(min_level..max_level)
        pbEndScene
        @main_menu_scene.pbEndScene
        spawn_pokeradar_pokemon(species,level)
      else
        pbMessage(_INTL("The battery is not charged enough for this scan!"))
      end
    else
      return
    end
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
    Kernel.pbDisplayText(_INTL("{1}/1000", battery_power), 460, HEADER_HEIGHT)
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

def spawn_pokeradar_pokemon(species,level)
  return unless species && level
  pbWait(20)
  playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, $game_player.x, $game_player.y)
  pbWait(10)
  spawned_events = spawn_ow_pokemon(species, level,1)
  #spawned_events = spawn_random_overworld_pokemon_group([species, level], 16, 1, nil, $PokemonEncounters.encounter_type)
  echoln "spawned events: #{spawned_events}"
  if spawned_events
    event = spawned_events[0]
    event.behavior_roaming = :look_around
    event.behavior_noticed = :flee
    playAnimation(Settings::POKERADAR_LIGHT_ANIMATION_RED_ID, event.x, event.y)
  else
    pbMessage(_INTL("The Pokéradar scan failed... Try again somewhere else"))
  end
end