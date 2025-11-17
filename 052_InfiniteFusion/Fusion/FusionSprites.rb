module GameData
  class Species
    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
      species = pkmn.species if !species
      species = GameData::Species.get(species).id_number # Just to be sure it's a number
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        ret = self.back_sprite_bitmap(species, pkmn.shiny?, pkmn.bodyShiny?, pkmn.headShiny?)
      else
        ret = self.front_sprite_bitmap(species, pkmn.shiny?, pkmn.bodyShiny?, pkmn.headShiny?)
      end
      ret.scale_bitmap(pkmn.sprite_scale) if ret #for pokemon with size differences
      return ret
    end



    def self.sprite_bitmap_from_pokemon_id(id, back = false, shiny = false, bodyShiny = false, headShiny = false)
      if back
        ret = self.back_sprite_bitmap(id,  shiny, bodyShiny, headShiny)
      else
        ret = self.front_sprite_bitmap(id,  shiny, bodyShiny, headShiny)
      end
      return ret
    end

    MAX_SHIFT_VALUE = 360
    MINIMUM_OFFSET = 40
    ADDITIONAL_OFFSET_WHEN_TOO_CLOSE = 40
    MINIMUM_DEX_DIF = 20

    def self.calculateShinyHueOffset(dex_number, isBodyShiny = false, isHeadShiny = false, color = :c1)
      if dex_number <= NB_POKEMON
        if SHINY_COLOR_OFFSETS[dex_number]&.dig(color)
          return SHINY_COLOR_OFFSETS[dex_number]&.dig(color)
        end
        body_number = dex_number
        head_number = dex_number
      else
        body_number = getBodyID(dex_number)
        head_number = getHeadID(dex_number, body_number)
      end
      if isBodyShiny && isHeadShiny && SHINY_COLOR_OFFSETS[body_number]&.dig(color) && SHINY_COLOR_OFFSETS[head_number]&.dig(color)
        offset = SHINY_COLOR_OFFSETS[body_number]&.dig(color) + SHINY_COLOR_OFFSETS[head_number]&.dig(color)
      elsif isHeadShiny && SHINY_COLOR_OFFSETS[head_number]&.dig(color)
        offset = SHINY_COLOR_OFFSETS[head_number]&.dig(color)
      elsif isBodyShiny && SHINY_COLOR_OFFSETS[body_number]&.dig(color)
        offset = SHINY_COLOR_OFFSETS[body_number]&.dig(color)
      else
        return 0 if color != :c1
        offset = calculateShinyHueOffsetDefaultMethod(body_number, head_number, dex_number, isBodyShiny, isHeadShiny)
      end
      return offset
    end


    def self.hex_to_rgb(hex)
      hex = hex.delete("#")
      r = hex[0..1].to_i(16)
      g = hex[2..3].to_i(16)
      b = hex[4..5].to_i(16)
      [r, g, b]
    end

    def self.calculateShinyHueOffsetDefaultMethod(body_number, head_number, dex_number, isBodyShiny = false, isHeadShiny = false)
      dex_offset = dex_number
      #body_number = getBodyID(dex_number)
      #head_number=getHeadID(dex_number,body_number)
      dex_diff = (body_number - head_number).abs
      if isBodyShiny && isHeadShiny
        dex_offset = dex_number
      elsif isHeadShiny
        dex_offset = head_number
      elsif isBodyShiny
        dex_offset = dex_diff > MINIMUM_DEX_DIF ? body_number : body_number + ADDITIONAL_OFFSET_WHEN_TOO_CLOSE
      end
      offset = dex_offset + Settings::SHINY_HUE_OFFSET
      offset /= MAX_SHIFT_VALUE if offset > NB_POKEMON
      offset = MINIMUM_OFFSET if offset < MINIMUM_OFFSET
      offset = MINIMUM_OFFSET if (MAX_SHIFT_VALUE - offset).abs < MINIMUM_OFFSET
      offset += pbGet(VAR_SHINY_HUE_OFFSET) #for testing - always 0 during normal gameplay
      return offset
    end

    def self.getAutogenSprite(head_id, body_id)

    end


  # species can be either a number, a Species objet of a symbol
    def self.front_sprite_bitmap(species, isShiny = false, bodyShiny = false, headShiny = false)
      dex_number = getDexNumberForSpecies(species)
      if species.is_a?(Species)
        dex_number = species.id_number
      end

      spriteLoader = BattleSpriteLoader.new
      if isFusion(dex_number)
        body_id = getBodyID(dex_number)
        head_id = getHeadID(dex_number, body_id)
        sprite = spriteLoader.load_fusion_sprite(head_id,body_id)
      else
        if isTripleFusion?(dex_number)
          sprite = spriteLoader.load_triple_fusion_sprite(dex_number)
        else
          sprite = spriteLoader.load_base_sprite(dex_number)
        end
      end
      if isShiny
        sprite.shiftAllColors(dex_number, bodyShiny, headShiny)
      end
      return sprite
    end






    # def self.front_sprite_bitmap(dex_number, isShiny = false, bodyShiny = false, headShiny = false)
    #   # body_id = getBodyID(dex_number)
    #   # head_id = getHeadID(dex_number, body_id)
    #   # return getAutogenSprite(head_id,body_id)
    #
    #   #la méthode est utilisé ailleurs avec d'autres arguments (gender, form, etc.) mais on les veut pas
    #   if dex_number.is_a?(Symbol)
    #     dex_number = GameData::Species.get(dex_number).id_number
    #   end
    #   filename = self.sprite_filename(dex_number)
    #   sprite = (filename) ? AnimatedBitmap.new(filename) : nil
    #   if isShiny
    #     sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
    #   end
    #   return sprite
    # end

    def self.back_sprite_bitmap(dex_number, isShiny = false, bodyShiny = false, headShiny = false)
      # filename = self.sprite_filename(dex_number)
      # sprite = (filename) ? AnimatedBitmap.new(filename) : nil
      # if isShiny
      #   sprite.shiftColors(self.calculateShinyHueOffset(dex_number, bodyShiny, headShiny))
      # end
      # return sprite
      sprite = self.front_sprite_bitmap(dex_number,isShiny,bodyShiny,headShiny)
      return sprite#.mirror
    end

    def self.egg_sprite_bitmap(dex_number, form = nil)
      filename = self.egg_sprite_filename(dex_number, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end
  end
end


    # def self.sprite_filename(dex_number)
    #   #dex_number = GameData::NAT_DEX_MAPPING[dex_number] ? GameData::NAT_DEX_MAPPING[dex_number] : dex_number
    #   if dex_number.is_a?(GameData::Species)
    #     dex_number = dex_number.id_number
    #   end
    #   if dex_number.is_a?(Symbol)
    #     dex_number = getDexNumberForSpecies(dex_number)
    #   end
    #   return nil if dex_number == nil
    #   if dex_number <= Settings::NB_POKEMON
    #     return get_unfused_sprite_path(dex_number)
    #   else
    #     if dex_number >= Settings::ZAPMOLCUNO_NB
    #       specialPath = getSpecialSpriteName(dex_number)
    #       return pbResolveBitmap(specialPath)
    #       head_id = nil
    #     else
    #       body_id = getBodyID(dex_number)
    #       head_id = getHeadID(dex_number, body_id)
    #       return get_fusion_sprite_path(head_id, body_id)
    #       # folder = head_id.to_s
    #       # filename = sprintf("%s.%s.png", head_id, body_id)
    #     end
    #   end
    #   # customPath = pbResolveBitmap(Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + "/" + head_id.to_s + "/" +filename)
    #   # customPath = download_custom_sprite(head_id,body_id)
    #   #
    #   # species = getSpecies(dex_number)
    #   # use_custom = customPath && !species.always_use_generated
    #   # if use_custom
    #   #   return customPath
    #   # end
    #   # #return Settings::BATTLERS_FOLDER + folder + "/" + filename
    #   # return download_autogen_sprite(head_id,body_id)
    # end


# def get_unfused_sprite_path(dex_number_id, localOnly = false)
#   dex_number = dex_number_id.to_s
#   folder = dex_number.to_s
#   substitution_id = "{1}", dex_number
#
#   if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(substitution_id)
#     substitutionPath = $PokemonGlobal.alt_sprite_substitutions[substitution_id]
#     return substitutionPath if pbResolveBitmap(substitutionPath)
#   end
#   random_alt = get_random_alt_letter_for_unfused(dex_number, true) #nil if no main
#   random_alt = "" if !random_alt || localOnly
#
#
#   filename = "{1}{2}.png", dex_number,random_alt
#
#   path = Settings::CUSTOM_BASE_SPRITES_FOLDER  + filename
#   if pbResolveBitmap(path)
#     record_sprite_substitution(substitution_id,path)
#     return path
#   end
#   echoln "downloading main sprite #{filename}"
#   downloaded_path = download_unfused_main_sprite(dex_number, random_alt) if !localOnly
#   if pbResolveBitmap(downloaded_path)
#     record_sprite_substitution(substitution_id,downloaded_path)
#     return downloaded_path
#   end
#   return path
# end

def alt_sprites_substitutions_available
  return $PokemonGlobal && $PokemonGlobal.alt_sprite_substitutions
end

def print_stack_trace
  stack_trace = caller
  stack_trace.each_with_index do |call, index|
    echo("#{index + 1}: #{call}")
  end
end

# def record_sprite_substitution(substitution_id, sprite_name)
#   return if !$PokemonGlobal
#   return if !$PokemonGlobal.alt_sprite_substitutions
#   $PokemonGlobal.alt_sprite_substitutions[substitution_id] = sprite_name
# end

def add_to_autogen_cache(pokemon_id, sprite_name)
  return if !$PokemonGlobal
  return if !$PokemonGlobal.autogen_sprites_cache
  $PokemonGlobal.autogen_sprites_cache[pokemon_id]=sprite_name
end

class PokemonGlobalMetadata
  attr_accessor :autogen_sprites_cache
end

#To force a specific sprites before a battle
#
#  ex:
# $PokemonTemp.forced_alt_sprites={"20.25" => "20.25a"}
#
class PokemonTemp
  attr_accessor :forced_alt_sprites
end

#todo:
# DO NOT USE ANYMORE
# Replace by BattleSpriteLoader
# def get_fusion_sprite_path(head_id, body_id, localOnly=false)
#   $PokemonGlobal.autogen_sprites_cache = {} if $PokemonGlobal && !$PokemonGlobal.autogen_sprites_cache
#   #Todo: ça va chier si on fusionne une forme d'un pokemon avec une autre forme, mais pas un problème pour tout de suite
#   form_suffix = ""
#
#   #Swap path if alt is selected for this pokemon
#   dex_num = getSpeciesIdForFusion(head_id, body_id)
#   substitution_id = dex_num.to_s + form_suffix
#
#   if alt_sprites_substitutions_available && $PokemonGlobal.alt_sprite_substitutions.keys.include?(substitution_id)
#     substitutionPath= $PokemonGlobal.alt_sprite_substitutions[substitution_id]
#     return substitutionPath if pbResolveBitmap(substitutionPath)
#   end
#
#
#   pokemon_name = "{1}.{2}",head_id, body_id
#
#   #get altSprite letter
#   random_alt = get_random_alt_letter_for_custom(head_id, body_id) #nil if no main
#   random_alt = "" if !random_alt
#   forcingSprite=false
#   if $PokemonTemp.forced_alt_sprites && $PokemonTemp.forced_alt_sprites.key?(pokemon_name)
#     random_alt = $PokemonTemp.forced_alt_sprites[pokemon_name]
#     forcingSprite=true
#   end
#
#
#   filename = "{1}{2}.png", pokemon_name, random_alt
#   #Try local custom sprite
#   local_custom_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + head_id.to_s  + "/" + filename
#   if pbResolveBitmap(local_custom_path)
#     record_sprite_substitution(substitution_id, local_custom_path) if !forcingSprite
#     return local_custom_path
#   end
#   #if the game has loaded an autogen earlier, no point in trying to redownload, so load that instead
#   return $PokemonGlobal.autogen_sprites_cache[substitution_id] if  $PokemonGlobal && $PokemonGlobal.autogen_sprites_cache[substitution_id]
#
#   #Try to download custom sprite if none found locally
#   downloaded_custom = download_custom_sprite(head_id, body_id, random_alt) if !localOnly
#   if downloaded_custom
#     record_sprite_substitution(substitution_id, downloaded_custom) if !forcingSprite
#     return downloaded_custom
#   end
#
#   #Try local generated sprite
#   local_generated_path = Settings::BATTLERS_FOLDER + head_id.to_s  + "/" + filename
#   if pbResolveBitmap(local_generated_path)
#     add_to_autogen_cache(substitution_id,local_generated_path)
#     return local_generated_path
#   end
#
#   #Download generated sprite if nothing else found
#   autogen_path = download_autogen_sprite(head_id, body_id) if !localOnly
#   if pbResolveBitmap(autogen_path)
#     add_to_autogen_cache(substitution_id,autogen_path)
#     return autogen_path
#   end
#
#   return Settings::DEFAULT_SPRITE_PATH
# end

def get_random_alt_letter_for_custom(head_id, body_id, onlyMain = true, weightedByArtist = true)
  spriteName = _INTL("{1}.{2}", head_id, body_id)
  return get_random_alt_letter(spriteName, onlyMain, weightedByArtist)
end

def get_random_alt_letter_for_unfused(dex_num, onlyMain = true, weightedByArtist = true)
  spriteName = _INTL("{1}", dex_num)
  return get_random_alt_letter(spriteName, onlyMain, weightedByArtist)
end

def get_random_alt_letter(spriteName, onlyMain = true, weightedByArtist = true)
  sprites = map_alt_sprite_letters_for_pokemon(spriteName)
  return nil if sprites.empty?

  if onlyMain
    tempList = sprites.select { |key, value| value[:status] == 'main' }
    tempList = sprites.select { |key, value| value[:status] == 'temp' } if tempList.empty?
    return nil if tempList.empty?
    sprites = tempList
  end

  return sprites.keys.sample if !weightedByArtist

  artists = {}
  sprites.each { |key, value| # count how many sprites each artist has
    sprites[key][:artist] = value[:artist] = sprites[key][:artist].split(' & ').map {|name| name.strip }.sort.join(' & ')  # keep collabs with different order as same artist
    artists[value[:artist]] = 0 if !artists.has_key?(value[:artist])
    artists[value[:artist]] += 1
  }

  hat = []
  factor = artists.reduce(1) { |acc, (artist, count)| acc.lcm(count) }
  sprites.each { |key, value|
    for i in 1..(factor / artists[value[:artist]]) do # more artist's sprites = fewer times in list
      hat << key
    end
  }
  return hat.sample # pick a sprite out of the hat
end

def list_main_sprites_letters(spriteName)
  return list_all_sprites_letters(spriteName) if $PokemonSystem.include_alt_sprites_in_random
  all_sprites = map_alt_sprite_letters_for_pokemon(spriteName)
  main_sprites = []
  all_sprites.each do |key, value|
    main_sprites << key if value[:status] == "main"
  end

  #add temp sprites if no main sprites found
  if main_sprites.empty?
    all_sprites.each do |key, value|
      main_sprites << key if value[:status] == "temp"
    end
  end
  return main_sprites
end

def list_all_sprites_letters_head_body(head_id,body_id)
  spriteName = _INTL("{1}.{2}", head_id, body_id)
  return map_alt_sprite_letters_for_pokemon(spriteName).keys
end

def list_all_sprites_letters(spriteName)
  return map_alt_sprite_letters_for_pokemon(spriteName).keys
end

def list_alt_sprite_letters(spriteName)
  all_sprites = map_alt_sprite_letters_for_pokemon(spriteName)
  alt_sprites = []
  all_sprites.each do |key, value|
    alt_sprites << key if value[:status] == "alt"
  end
  return alt_sprites
end


#ex: "1" -> { :status => "main", :artist => "urbain" }
#    "1a" -> { :status => "alt", :artist => "taunie" }
def map_alt_sprite_letters_for_pokemon(spriteName)
  parts = spriteName.split('.')
  is_triple = parts[2] != nil
  is_fusion = !is_triple && parts[1] != nil

  alt_sprites = {}
  File.foreach(Settings::CREDITS_FILE_PATH) do |line|
    row = line.split(',')
    sprite_name = row[0].strip

    next if is_triple && !sprite_name.match(Regexp.new("^#{parts[0]}\\.#{parts[1]}\\.#{parts[2]}[a-z]*$"))
    next if is_fusion && !sprite_name.match(Regexp.new("^#{parts[0]}\\.#{parts[1]}[a-z]*$"))
    next if !is_triple && !is_fusion && !sprite_name.match(Regexp.new("^#{parts[0]}[a-z]*$"))

    alt_sprites[sprite_name[/[a-z]+/] || ""] = { :status => row[2], :artist => row[1] }
  end
  return alt_sprites
end