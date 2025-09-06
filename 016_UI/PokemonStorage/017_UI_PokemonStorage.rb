#===============================================================================
# Pokémon icons
#===============================================================================
class PokemonBoxIcon < IconSprite
  attr_accessor :pokemon

  def initialize(pokemon, viewport = nil)
    super(0, 0, viewport)
    @pokemon = pokemon
    @release = Interpolator.new
    @startRelease = false
    refresh
  end

  def releasing?
    return @release.tweening?
  end

  def useRegularIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return true if dexNum <= Settings::NB_POKEMON
    return false if $game_variables == nil
    return true if $game_variables[VAR_FUSION_ICON_STYLE] != 0
    bitmapFileName = sprintf("Graphics/Icons/icon%03d", dexNum)
    return true if pbResolveBitmap(bitmapFileName)
    return false
  end

  def createFusionIcon(species, spriteform_head = nil, spriteform_body = nil)
    bodyPoke_number = getBodyID(species)
    headPoke_number = getHeadID(species, bodyPoke_number)

    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    icon1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke, spriteform_head))
    icon2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke, spriteform_body))

    dexNum = getDexNumberForSpecies(species)
    ensureFusionIconExists
    bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
    headPokeFileName = GameData::Species.icon_filename(headPoke, spriteform_head)
    bitmapPath = sprintf("%s.png", bitmapFileName)
    generated_new_icon = generateFusionIcon(headPokeFileName, bitmapPath)
    result_icon = generated_new_icon ? AnimatedBitmap.new(bitmapPath) : icon1

    for i in 0..icon1.width - 1
      for j in ((icon1.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)..icon1.height - 1
        temp = icon2.bitmap.get_pixel(i, j)
        result_icon.bitmap.set_pixel(i, j, temp)
      end
    end
    return result_icon
  end

  def release
    self.ox = self.src_rect.width / 2 # 32
    self.oy = self.src_rect.height / 2 # 32
    self.x += self.src_rect.width / 2 # 32
    self.y += self.src_rect.height / 2 # 32
    @release.tween(self, [
      [Interpolator::ZOOM_X, 0],
      [Interpolator::ZOOM_Y, 0],
      [Interpolator::OPACITY, 0]
    ], 100)
    @startRelease = true
  end

  def refresh(fusion_enabled = true)
    return if !@pokemon
    if useRegularIcon(@pokemon.species) || @pokemon.egg?
      self.setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon))
    else
      self.setBitmapDirectly(createFusionIcon(@pokemon.species, @pokemon.spriteform_head, @pokemon.spriteform_body))
      if fusion_enabled
        self.visible = true
      else
        self.visible = false
      end
    end
    self.src_rect = Rect.new(0, 0, self.bitmap.height, self.bitmap.height)
  end

  def update
    super
    @release.update
    self.color = Color.new(0, 0, 0, 0)
    dispose if @startRelease && !releasing?
  end
end

#===============================================================================
# Pokémon sprite
#===============================================================================
class MosaicPokemonSprite < PokemonSprite
  attr_reader :mosaic

  def initialize(*args)
    super(*args)
    @mosaic = 0
    @inrefresh = false
    @mosaicbitmap = nil
    @mosaicbitmap2 = nil
    @oldbitmap = self.bitmap
  end

  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap = nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2 = nil
  end

  def bitmap=(value)
    super
    mosaicRefresh(value)
  end

  def mosaic=(value)
    @mosaic = value
    @mosaic = 0 if @mosaic < 0
    mosaicRefresh(@oldbitmap)
  end

  def mosaicRefresh(bitmap)
    return if @inrefresh
    @inrefresh = true
    @oldbitmap = bitmap
    if @mosaic <= 0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap = nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2 = nil
      self.bitmap = @oldbitmap
    else
      newWidth = [(@oldbitmap.width / @mosaic), 1].max
      newHeight = [(@oldbitmap.height / @mosaic), 1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap, newWidth, newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2, @oldbitmap.width, @oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @oldbitmap, @oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
        Rect.new(-@mosaic / 2 + 1, -@mosaic / 2 + 1,
                 @mosaicbitmap2.width, @mosaicbitmap2.height),
        @mosaicbitmap, Rect.new(0, 0, newWidth, newHeight))
      self.bitmap = @mosaicbitmap2
    end
    @inrefresh = false
  end
end

#===============================================================================
#
#===============================================================================
class AutoMosaicPokemonSprite < MosaicPokemonSprite
  def update
    super
    self.mosaic -= 1
  end
end

#===============================================================================
# Cursor
#===============================================================================
class PokemonBoxArrow < SpriteWrapper
  attr_accessor :quickswap

  def initialize(viewport = nil)
    super(viewport)
    @frame = 0
    @holding = false
    @updating = false
    @quickswap = false
    @grabbingState = 0
    @placingState = 0
    @heldpkmn = nil
    @handsprite = ChangelingSprite.new(0, 0, viewport)
    @handsprite.addBitmap("point1", "Graphics/Pictures/Storage/cursor_point_1")
    @handsprite.addBitmap("point2", "Graphics/Pictures/Storage/cursor_point_2")
    @handsprite.addBitmap("grab", "Graphics/Pictures/Storage/cursor_grab")
    @handsprite.addBitmap("fist", "Graphics/Pictures/Storage/cursor_fist")
    @handsprite.addBitmap("point1q", "Graphics/Pictures/Storage/cursor_point_1_q")
    @handsprite.addBitmap("point2q", "Graphics/Pictures/Storage/cursor_point_2_q")
    @handsprite.addBitmap("grabq", "Graphics/Pictures/Storage/cursor_grab_q")
    @handsprite.addBitmap("fistq", "Graphics/Pictures/Storage/cursor_fist_q")

    @handsprite.addBitmap("fusion_dnasplicer", "Graphics/Pictures/Storage/cursor_dnasplicer")
    @handsprite.addBitmap("fusion_supersplicer", "Graphics/Pictures/Storage/cursor_supersplicer")
    @handsprite.addBitmap("fusion_infinitesplicer", "Graphics/Pictures/Storage/cursor_infinitesplicer")
    @handsprite.addBitmap("fusion_infinitesplicer2", "Graphics/Pictures/Storage/cursor_infinitesplicer2")

    @handsprite.changeBitmap("fist")
    @spriteX = self.x
    @spriteY = self.y
    @splicerType = 0
  end

  def dispose
    @handsprite.dispose
    @heldpkmn.dispose if @heldpkmn
    super
  end

  # 0 :DNASPLICERS
  # 1: SUPERSPLICERS
  # 2: INFINITESPLICERS
  # 3: INFINITESPLICERS2
  def getSplicerIcon
    case @splicerType
    when 3
      return "fusion_dnasplicer"
    when 2
      return "fusion_infinitesplicer"
    when 1
      return "fusion_supersplicer"
    else
     return "fusion_dnasplicer"
    end
  end

  def setSplicerType(type)
    @splicerType = type
  end

  def setFusing(fusing)
    @fusing = fusing
  end

  def fusing?
    return @fusing
  end

  def heldPokemon
    @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
    @holding = false if !@heldpkmn
    return @heldpkmn
  end

  def visible=(value)
    super
    @handsprite.visible = value
    sprite = heldPokemon
    sprite.visible = value if sprite
  end

  def color=(value)
    super
    @handsprite.color = value
    sprite = heldPokemon
    sprite.color = value if sprite
  end

  def holding?
    return self.heldPokemon && @holding
  end

  def grabbing?
    return @grabbingState > 0
  end

  def placing?
    return @placingState > 0
  end

  def x=(value)
    super
    @handsprite.x = self.x
    @spriteX = x if !@updating
    heldPokemon.x = self.x if holding?
  end

  def y=(value)
    super
    @handsprite.y = self.y
    @spriteY = y if !@updating
    heldPokemon.y = self.y + 16 if holding?
  end

  def z=(value)
    super
    @handsprite.z = value
  end

  def setSprite(sprite)
    if holding?
      @heldpkmn = sprite
      @heldpkmn.viewport = self.viewport if @heldpkmn
      @heldpkmn.z = 1 if @heldpkmn
      @holding = false if !@heldpkmn
      self.z = 2
    end
  end

  def deleteSprite
    @holding = false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn = nil
    end
  end

  def grab(sprite)
    @grabbingState = 1
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2
  end

  def place
    @placingState = 1
  end

  def release
    @heldpkmn.release if @heldpkmn
  end

  def update
    @updating = true
    super
    heldpkmn = heldPokemon
    heldpkmn.update if heldpkmn
    @handsprite.update
    @holding = false if !heldpkmn

    if @fusionMode
      @handsprite.changeBitmap(getSplicerIcon)
    elsif @grabbingState > 0
      if @grabbingState <= 4 * Graphics.frame_rate / 20
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY + 4.0 * @grabbingState * 20 / Graphics.frame_rate
        @grabbingState += 1
      elsif @grabbingState <= 8 * Graphics.frame_rate / 20
        @holding = true
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @grabbingState) * 20 / Graphics.frame_rate
        @grabbingState += 1
      else
        @grabbingState = 0
      end
    elsif @placingState > 0
      if @placingState <= 4 * Graphics.frame_rate / 20
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY + 4.0 * @placingState * 20 / Graphics.frame_rate
        @placingState += 1
      elsif @placingState <= 8 * Graphics.frame_rate / 20
        @holding = false
        @heldpkmn = nil
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @placingState) * 20 / Graphics.frame_rate
        @placingState += 1
      else
        @placingState = 0
      end
    elsif holding?
      @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
    else
      self.x = @spriteX
      self.y = @spriteY
      if @frame < Graphics.frame_rate / 2
        @handsprite.changeBitmap((@quickswap) ? "point1q" : "point1")
      else
        @handsprite.changeBitmap((@quickswap) ? "point2q" : "point2")
      end
    end
    @frame += 1
    @frame = 0 if @frame >= Graphics.frame_rate
    @updating = false
  end
end

#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites

  def initialize(storage, boxnumber, viewport = nil, fusionsEnabled = true)
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @pokemonsprites = []
    for i in 0...PokemonBox::BOX_SIZE
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber, i]
      @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
    end
    @contents = BitmapWrapper.new(324, 296)
    self.bitmap = @contents
    self.x = 184
    self.y = 18

    @fusions_enabled = fusionsEnabled
    refresh
  end

  def disableFusions()
    @fusions_enabled = false
    refreshAllBoxSprites()
  end

  def enableFusions()
    @fusions_enabled = true
    refreshAllBoxSprites()
  end

  def isFusionEnabled
    return @fusions_enabled
  end

  def dispose
    if !disposed?
      for i in 0...PokemonBox::BOX_SIZE
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @boxbitmap.dispose
      @contents.dispose
      super
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...PokemonBox::BOX_SIZE
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg != @storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || (curbg.is_a?(String) && curbg.length == 0)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
      else
        if curbg.is_a?(String) && curbg[/^box(\d+)$/]
          curbg = $~[1].to_i
          @storage[@boxnumber].background = curbg
        end
        @bg = curbg
      end
      if !@storage.isAvailableWallpaper?(@bg)
        @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
        @storage[@boxnumber].background = @bg
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/Wallpapers/box_#{@bg}")
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites[index].refresh
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      update
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    update
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 324, 296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      xval = 162 - (widthval / 2)
      pbDrawShadowText(@contents, xval, 8, widthval, 32,
                       boxname, Color.new(248, 248, 248), Color.new(40, 48, 48))
      @refreshBox = false
    end
    yval = self.y + 30
    for j in 0...PokemonBox::BOX_HEIGHT
      xval = self.x + 10
      for k in 0...PokemonBox::BOX_WIDTH
        sprite = @pokemonsprites[j * PokemonBox::BOX_WIDTH + k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.x = xval
          sprite.y = yval
          sprite.z = 1
        end
        xval += 48
      end
      yval += 48
    end
  end

  def refreshAllBoxSprites
    # spriteLoader = BattleSpriteLoader.new
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].refresh(@fusions_enabled)
      end
      # spriteLoader.preload_sprite_from_pokemon(@pokemonsprites[i].pokemon) if @pokemonsprites[i].pokemon
    end
  end

  def update
    super
    for i in 0...PokemonBox::BOX_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end

#===============================================================================
# Party pop-up panel
#===============================================================================
class PokemonBoxPartySprite < SpriteWrapper
  def initialize(party, viewport = nil)
    super(viewport)
    @party = party
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/overlay_party")
    @pokemonsprites = []
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
      end
    end
    @contents = BitmapWrapper.new(172, 352)
    self.bitmap = @contents
    self.x = 182
    self.y = Graphics.height - 352
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
    @boxbitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color, value)
      end
    end
  end

  def visible=(value)
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index, sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index, arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    @pokemonsprites.compact!
    refresh
  end

  def refresh
    @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 172, 352))
    pbDrawTextPositions(self.bitmap, [
      [_INTL("Back"), 86, 240, 2, Color.new(248, 248, 248), Color.new(80, 80, 80), 1]
    ])
    xvalues = [] # [18, 90, 18, 90, 18, 90]
    yvalues = [] # [2, 18, 66, 82, 130, 146]
    for i in 0...Settings::MAX_PARTY_SIZE
      xvalues.push(18 + 72 * (i % 2))
      yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
    end
    for j in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...Settings::MAX_PARTY_SIZE
      sprite = @pokemonsprites[j]
      next if sprite.nil? || sprite.disposed?
      sprite.viewport = self.viewport
      sprite.x = self.x + xvalues[j]
      sprite.y = self.y + yvalues[j]
      sprite.z = 1
    end
  end

  def update
    super
    for i in 0...Settings::MAX_PARTY_SIZE
      @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
    end
  end
end




