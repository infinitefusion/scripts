class SafariCaughtIcons_UI < PokeRadar_UI
  SAFARI_ICON_START_X    = 8
  SAFARI_ICON_START_Y    = 40
  SAFARI_ICON_SPACING_X  = 24   # gap between dupes
  SAFARI_ICON_MARGIN_Y   = 44
  SAFARI_ICON_MIN_MARGIN = 24
  SAFARI_ICON_BOTTOM     = 8
  SAFARI_ICON_RIGHT      = 8
  SAFARI_GRAPHICS_Z      = 99998

  def initialize(caught_pokemon = [])
    counts = Hash.new(0)
    caught_pokemon.each { |species| counts[species] += 1 }

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = SAFARI_GRAPHICS_Z
    @sprites = {}

    available_height = Graphics.height - SAFARI_ICON_START_Y - SAFARI_ICON_BOTTOM
    row_margin = SAFARI_ICON_MARGIN_Y
    if counts.size > 0
      row_margin = [[available_height / counts.size, SAFARI_ICON_MARGIN_Y].min,
                    SAFARI_ICON_MIN_MARGIN].max
    end

    y = SAFARI_ICON_START_Y
    counts.each do |species, count|
      addSpeciesRow(species, count, y)
      y += row_margin
    end
  end

  def addSpeciesRow(species, count, y)
    pokemonId = dexNum(species)
    return if !pokemonId
    available_width = Graphics.width - SAFARI_ICON_START_X - SAFARI_ICON_RIGHT - 32
    spacing = SAFARI_ICON_SPACING_X
    spacing = [available_width / (count - 1), spacing].min if count > 1

    count.times do |i|
      x = SAFARI_ICON_START_X + i * spacing

      if pokemonId > NB_POKEMON
        iconSprite = createFusionIcon(pokemonId, x, y)
      else
        iconSprite = IconSprite.new(x, y)
        iconSprite.setBitmap(pbCheckPokemonIconFiles(species))
      end

      iconSprite.src_rect.width /= 2 # icon sheets have 2 frames, show only the first
      iconSprite.x = x
      iconSprite.y = y
      iconSprite.z = SAFARI_GRAPHICS_Z + 1 + i
      iconSprite.visible = true
      @sprites[_INTL("{1}_{2}", species, i)] = iconSprite
    end
  end
end

def displayCaughtPokemonIcons
  pbSafariState.caught_pokemon = [] unless pbSafariState.caught_pokemon
  return SafariCaughtIcons_UI.new(pbSafariState.caught_pokemon)
end