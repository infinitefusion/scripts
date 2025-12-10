def splitSpriteCredits(name, bitmap, max_width)
  return [name] if bitmap.text_size(name).width <= max_width

  parts = name.split(" & ")
  lines = []

  parts.each_with_index do |part, i|
    segment = part
    segment += " &" if i < parts.length - 1   # keep & with the left segment

    # If this segment fits, just add it
    if bitmap.text_size(segment).width <= max_width
      lines << segment
      next
    end

    # Otherwise split inside the segment
    current = segment.dup
    while bitmap.text_size(current).width > max_width
      # Try to break at last space within limit
      break_pos = nil
      j = 0
      while j = current.index(" ", j)
        if bitmap.text_size(current[0, j]).width <= max_width
          break_pos = j
        else
          break
        end
        j += 1
      end

      if break_pos
        # split at last valid space
        lines << current[0, break_pos].strip
        current = current[break_pos + 1..].strip
      else
        # no spaces at all: hard split by characters
        # find max chars that fit
        k = current.length - 1
        k -= 1 while bitmap.text_size(current[0, k]).width > max_width
        lines << current[0, k]
        current = current[k..].strip
      end
    end

    lines << current unless current.empty?
  end

  lines
end


def pbLoadPokemonBitmapSpecies(pokemon, species, back = false, scale = POKEMONSPRITESCALE)
  ret = nil
  pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
  if pokemon.isEgg?
    bitmapFileName = getEggBitmapPath(pokemon)
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  elsif pokemon.species >= ZAPMOLCUNO_NB #zapmolcuno
    bitmapFileName = getSpecialSpriteName(pokemon.species) #sprintf("Graphics/Battlers/special/144.145.146")
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    #edited here
    isFusion = species > NB_POKEMON
    if isFusion
      poke1 = getBodyID(species)
      poke2 = getHeadID(species, poke1)
    else
      poke1 = species
      poke2 = species
    end
    bitmapFileName = GetSpritePath(poke1, poke2, isFusion)
    # Alter bitmap if supported
    alterBitmap = (MultipleForms.getFunction(species, "alterBitmap") rescue nil)
  end
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each { |bitmap| alterBitmap.call(pokemon, bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName)
  end
  return ret
end

def pbPokemonBitmapFile(species)
  # Used by the Pokédex
  # Load normal bitmap
  #get body and head num
  isFused = species > NB_POKEMON
  if isFused
    if species >= ZAPMOLCUNO_NB
      path = getSpecialSpriteName(species) + ".png"
    else
      poke1 = getBodyID(species) #getBasePokemonID(species,true)
      poke2 = getHeadID(species, poke1) #getBasePokemonID(species,false)
      path = GetSpritePath(poke1, poke2, isFused)
    end
  else
    path = GetSpritePath(species, species, false)
  end
  ret = sprintf(path) rescue nil
  if !pbResolveBitmap(ret)
    ret = "Graphics/Battlers/000.png"
  end
  return ret
end


def pbLoadPokemonBitmap(pokemon, species, back = false)
  #species est utilisé par elitebattle mais ca sert a rien
  return pbLoadPokemonBitmapSpecies(pokemon, pokemon.species, back)
end

def getEggBitmapPath(pokemon)
  return "Graphics/Battlers/Eggs/000" if $PokemonSystem.hide_custom_eggs
  bitmapFileName = sprintf("Graphics/Battlers/Eggs/%s", getConstantName(PBSpecies, pokemon.species)) rescue nil
  if !pbResolveBitmap(bitmapFileName)
    if pokemon.species >= NUM_ZAPMOLCUNO
      bitmapFileName = "Graphics/Battlers/Eggs/egg_base"
    else
      bitmapFileName = sprintf("Graphics/Battlers/Eggs/%03d", pokemon.species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/Eggs/000")
      end
    end
  end
  return bitmapFileName
end

def GetSpritePath(poke1, poke2, isFused)
  #Check if custom exists
  spritename = GetSpriteName(poke1, poke2, isFused)
  pathCustom = sprintf("Graphics/%s/indexed/%s/%s.png", DOSSIERCUSTOMSPRITES,poke2, spritename)
  pathReg = sprintf("Graphics/%s/%s/%s.png", BATTLERSPATH, poke2, spritename)
  path = pbResolveBitmap(pathCustom) && $game_variables[196] == 0 ? pathCustom : pathReg
  return path
end


def GetSpritePathForced(poke1, poke2, isFused)
  #Check if custom exists
  spritename = GetSpriteName(poke1, poke2, isFused)
  pathCustom = sprintf("Graphics/%s/indexed/%s/%s.png", DOSSIERCUSTOMSPRITES, poke2, spritename)
  pathReg = sprintf("Graphics/%s/%s/%s.png", BATTLERSPATH, poke2, spritename)
  path = pbResolveBitmap(pathCustom) ? pathCustom : pathReg
  return path
end


def GetSpriteName(poke1, poke2, isFused)
  ret = isFused ? sprintf("%d.%d", poke2, poke1) : sprintf("%d", poke2) rescue nil
  return ret
end