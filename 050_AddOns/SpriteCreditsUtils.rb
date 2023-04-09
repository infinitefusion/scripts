def map_sprites_by_artist
  creditsMap = Hash.new
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    spritename = row[0]
    artist = row[1].chomp
    sprites = creditsMap.key?(artist) ? creditsMap[artist] : []
    sprites << spritename
    creditsMap[artist] = sprites
  end
  return creditsMap
end

def analyzeSpritesList(spritesList)
  pokemon_map = Hash.new
  for spritename in spritesList
    splitName = spritename.split(".")
    headNum = splitName[0].to_i
    bodyNum = splitName[1].to_i

    if pokemon_map.key?(headNum)
      pokemon_map[headNum] += 1
    else
      pokemon_map[headNum] = 1
    end

    if pokemon_map.key?(bodyNum)
      pokemon_map[bodyNum] += 1
    else
      pokemon_map[bodyNum] = 1
    end
  end
  most_popular =  pokemon_map.max_by { |key, value| value }[0]
  species = getSpecies(most_popular)

  return  species
end

def getPokemonSpeciesFromSprite(spritename)
  splitName = spritename.split(".")
  headNum = splitName[0].to_i
  bodyNum = splitName[1].to_i

  #call this to make sure that the sprite is downloaded
  get_fusion_sprite_path(headNum, bodyNum)

  species = getFusionSpecies(bodyNum, headNum)
  return species
end

def doesCurrentExhibitionFeaturePokemon(displayedSprites,pokemon)
  for sprite in displayedSprites
    parts = sprite.split(".")
    headNum = parts[0].to_i
    bodyNum = parts[1].to_i
    return true if headNum == pokemon.id_number || bodyNum == pokemon.id_number
  end
  return false
end

def generateArtGallery(nbSpritesDisplayed = 6, saveArtistNameInVariable = 1, saveSpritesInVariable = 2, saveAllArtistSpritesInVariable=3,artistName=nil)
  creditsMap = map_sprites_by_artist
  featuredArtist = artistName ? artistName : getRandomSpriteArtist(creditsMap, nbSpritesDisplayed)
  if featuredArtist
    featuredSprites = creditsMap[featuredArtist].shuffle.take(nbSpritesDisplayed)
    pbSet(saveArtistNameInVariable, File.basename(featuredArtist, '#*'))
    pbSet(saveSpritesInVariable, featuredSprites)
    pbSet(saveAllArtistSpritesInVariable, creditsMap[featuredArtist])
    return featuredSprites
  end
  return nil
end

def getRandomSpriteArtist(creditsMap = nil, minimumNumberOfSprites = 1, giveUpAfterX = 50)
  creditsMap = map_sprites_by_artist if !creditsMap
  i = 0
  while i < giveUpAfterX
    artist = creditsMap.keys.sample
    return artist if creditsMap[artist].length >= minimumNumberOfSprites
  end
  return nil
end

def getSpriteCredits(spriteName)
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    if row[0].include?(spriteName)
      return row[1]
    end
  end
  return nil
end