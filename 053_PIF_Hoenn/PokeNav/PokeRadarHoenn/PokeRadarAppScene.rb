
#todo:
# When all pokemon in the route are seen, can "scan" for species
#  - spawns a pokemon of that species nearby with notice behavior to flee
class PokeRadarAppScene < PokeNavAppScene

  def pbStartScene()
    echoln 'START'
    @unseenPokemon = listPokemonInCurrentRoute($PokemonEncounters.encounter_type, false, true)
    @seenPokemon = listPokemonInCurrentRoute($PokemonEncounters.encounter_type, true, false)
    echoln @unseenPokemon
    buttons = []
    @seenPokemon.each do |pokemon_species|
      echoln pokemon_species
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path,false)
      button = PokenavButton.new(pokemon_species, bmp)
      button.crop_width = button.source_bitmap.bitmap.width / 2
      buttons << button if button
    end
    @unseenPokemon.each do |pokemon_species|
      echoln pokemon_species
      icon_path = pbCheckPokemonIconFiles(pokemon_species)
      bmp = load_bitmap(icon_path,true)
      button = PokenavButton.new(pokemon_species, bmp)
      button.crop_width = button.source_bitmap.bitmap.width / 2
      button.refresh
      buttons << button
    end
    super(buttons)
  end

  def load_bitmap(path, dark=false)
    return nil unless path && path != ""
    bmp = Bitmap.new(path)
    if dark
      bmp.fill_rect(Rect.new(0, 0, bmp.width, bmp.height), Color.new(0, 0, 0, 150))
    end
    return AnimatedBitmap.from_bitmap(bmp)
  end

  def display_mode
    return :GRID
  end

  def x_gap
    return 50;
  end

  def y_gap
    return 50;
  end

end
