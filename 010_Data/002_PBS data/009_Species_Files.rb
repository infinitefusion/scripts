module GameData
  class Species
    def self.check_graphic_file(path, species, form = "", gender = 0, shiny = false, shadow = false, subfolder = "")
      try_subfolder = sprintf("%s/", subfolder)
      try_species = species

      try_form = form ? sprintf("_%s", form) : ""
      try_gender = (gender == 1) ? "_female" : ""
      try_shadow = (shadow) ? "_shadow" : ""
      factors = []
      factors.push([4, sprintf("%s shiny/", subfolder), try_subfolder]) if shiny
      factors.push([3, try_shadow, ""]) if shadow
      factors.push([2, try_gender, ""]) if gender == 1
      factors.push([1, try_form, ""]) if form
      factors.push([0, try_species, "000"])
      # Go through each combination of parameters in turn to find an existing sprite
      for i in 0...2 ** factors.length
        # Set try_ parameters for this combination
        factors.each_with_index do |factor, index|
          value = ((i / (2 ** index)) % 2 == 0) ? factor[1] : factor[2]
          case factor[0]
          when 0
            try_species = value
          when 1
            try_form = value
          when 2
            try_gender = value
          when 3
            try_shadow = value
          when 4
            try_subfolder = value # Shininess
          end
        end
        # Look for a graphic matching this combination's parameters
        try_species_text = try_species
        ret = pbResolveBitmap(sprintf("%s%s%s%s%s%s", path, try_subfolder,
                                      try_species_text, try_form, try_gender, try_shadow))
        return ret if ret
      end
      return nil
    end

    def self.check_egg_graphic_file(path, species, form, suffix = "")
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      if form > 0
        ret = pbResolveBitmap(sprintf("%s%s_%d%s", path, species_data.species, form, suffix))
        return ret if ret
      end
      return pbResolveBitmap(sprintf("%s%s%s", path, species_data.species, suffix))
    end

    def self.front_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      return self.check_graphic_file("Graphics/Pokemon/", species, form, gender, shiny, shadow, "Front")
    end

    def self.back_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      return self.check_graphic_file("Graphics/Pokemon/", species, form, gender, shiny, shadow, "Back")
    end

    # def self.egg_sprite_filename(species, form)
    #   ret = self.check_egg_graphic_file("Graphics/Pokemon/Eggs/", species, form)
    #   return (ret) ? ret : pbResolveBitmap("Graphics/Pokemon/Eggs/000")
    # end
    def self.egg_sprite_filename(species, form)
      return "Graphics/Battlers/Eggs/000" if $PokemonSystem.use_custom_eggs
      dexNum = getDexNumberForSpecies(species)
      bitmapFileName = sprintf("Graphics/Battlers/Eggs/%03d", dexNum) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        if isTripleFusion?(dexNum)
          bitmapFileName = "Graphics/Battlers/Eggs/egg_base"
        else
          bitmapFileName = sprintf("Graphics/Battlers/Eggs/%03d", dexNum)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/Eggs/000")
          end
        end
      end
      return bitmapFileName
    end

    def self.sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false)
      return self.egg_sprite_filename(species, form) if egg
      return self.back_sprite_filename(species, form, gender, shiny, shadow) if back
      return self.front_sprite_filename(species, form, gender, shiny, shadow)
    end

    def self.front_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
      #filename = self.front_sprite_filename(species, form, gender, shiny, shadow)
      filename = self.front_sprite_filename(GameData::Species.get(species).id_number)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.back_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
      filename = self.back_sprite_filename(species, form, gender, shiny, shadow)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.egg_sprite_bitmap(species, form = 0)
      filename = self.egg_sprite_filename(species, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false)
      return self.egg_sprite_bitmap(species, form) if egg
      return self.back_sprite_bitmap(species, form, gender, shiny, shadow) if back
      return self.front_sprite_bitmap(species, shiny)
    end

    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
      species = pkmn.species if !species
      species = GameData::Species.get(species).species # Just to be sure it's a symbol
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      if back
        ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
      else
        ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
      end
      alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
      if ret && alter_bitmap_function
        new_ret = ret.copy
        ret.dispose
        new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
        ret = new_ret
      end
      print "hat"
      add_hat_to_bitmap(ret, pkmn.hat, pkmn.hat_x, pkmn.hat_y) if pkmn.hat
      return ret
    end

    #===========================================================================

    def self.egg_icon_filename(species, form)
      ret = self.check_egg_graphic_file("Graphics/Pokemon/Eggs/", species, form, "_icon")
      return (ret) ? ret : pbResolveBitmap("Graphics/Pokemon/Eggs/000_icon")
    end

    def self.icon_filename(species, spriteform = nil, gender = nil, shiny = false, shadow = false, egg = false)
      return self.egg_icon_filename(species, 0) if egg
      return self.check_graphic_file("Graphics/Pokemon/", species, spriteform, gender, shiny, shadow, "Icons")
    end

    def self.icon_filename_from_pokemon(pkmn)
      return pbResolveBitmap(sprintf("Graphics/Icons/iconEgg")) if pkmn.egg?
      if pkmn.isFusion?
        return pbResolveBitmap(sprintf("Graphics/Icons/iconDNA"))
      end
      return self.icon_filename(pkmn.species, pkmn.spriteform_head, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?)
    end

    def self.icon_filename_from_species(species)
      return self.icon_filename(species, 0, 0, false, false, false)
    end

    def self.egg_icon_bitmap(species, form)
      filename = self.egg_icon_filename(species, form)
      return (filename) ? AnimatedBitmap.new(filename).deanimate : nil
    end

    def self.icon_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
      filename = self.icon_filename(species, form, gender, shiny, shadow)
      return (filename) ? AnimatedBitmap.new(filename).deanimate : nil
    end

    def self.icon_bitmap_from_pokemon(pkmn)
      return self.icon_bitmap(pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?)
    end

    #===========================================================================

    def self.footprint_filename(species, form = 0)
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      if form > 0
        ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s_%d", species_data.species, form))
        return ret if ret
      end
      return pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s", species_data.species))
    end

    #===========================================================================

    def self.shadow_filename(species, form = 0)
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      # Look for species-specific shadow graphic
      if form > 0
        ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s_%d", species_data.species, form))
        return ret if ret
      end
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s", species_data.species))
      return ret if ret
      # Use general shadow graphic
      return pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%d", species_data.shadow_size))
    end

    def self.shadow_bitmap(species, form = 0)
      filename = self.shadow_filename(species, form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.shadow_bitmap_from_pokemon(pkmn)
      filename = self.shadow_filename(pkmn.species, pkmn.form)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    #===========================================================================

    def self.check_cry_file(species, form)
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      if species_data.is_fusion
        species_data = GameData::Species.get(getHeadID(species_data))
      end
      ret = sprintf("Cries/%s", species_data.species)
      return (pbResolveAudioSE(ret)) ? ret : nil
    end

    def self.cry_filename(species, form = 0)
      return self.check_cry_file(species, form)
    end

    def self.cry_filename_from_pokemon(pkmn)
      return self.check_cry_file(pkmn.species, pkmn.form)
    end

    def self.play_cry_from_species(species, form = 0, volume = 90, pitch = 100)
      dex_num = getDexNumberForSpecies(species)
      return if !dex_num
      return play_triple_fusion_cry(species, volume, pitch) if dex_num > Settings::ZAPMOLCUNO_NB
      if dex_num > NB_POKEMON
        body_number = getBodyID(dex_num)
        head_number = getHeadID(dex_num, body_number)
        return play_fusion_cry(GameData::Species.get(head_number).species, GameData::Species.get(body_number).species, volume, pitch)
      end
      filename = self.cry_filename(species, form)
      return if !filename
      pbSEPlay(RPG::AudioFile.new(filename, volume, pitch)) rescue nil
    end

    def self.play_cry_from_pokemon(pkmn, volume = 90, pitch = nil)
      return if !pkmn || pkmn.egg?

      species_data = pkmn.species_data
      return play_triple_fusion_cry(pkmn.species, volume, pitch) if species_data.is_triple_fusion
      if pkmn.species_data.is_fusion
        return play_fusion_cry(species_data.get_head_species, species_data.get_body_species, volume, pitch)
      end
      filename = self.cry_filename_from_pokemon(pkmn)
      return if !filename
      pitch ||= 75 + (pkmn.hp * 25 / pkmn.totalhp)
      pbSEPlay(RPG::AudioFile.new(filename, volume, pitch)) rescue nil
    end

    def self.play_triple_fusion_cry(species_id, volume, pitch)
      fusion_components = get_triple_fusion_components(species_id)

      echoln fusion_components
      echoln species_id
      for id in fusion_components
        cry_filename = self.check_cry_file(id, nil)
        pbSEPlay(cry_filename, volume - 10) rescue nil
      end
    end
    def self.play_fusion_cry(head_id, body_id, volume = 90, pitch = 100)
      head_cry_filename = self.check_cry_file(head_id, nil)
      body_cry_filename = self.check_cry_file(body_id, nil)

      pbSEPlay(body_cry_filename, volume - 10) rescue nil
      pbSEPlay(head_cry_filename, volume) rescue nil
    end
    def self.play_cry(pkmn, volume = 90, pitch = nil)
      if pkmn.is_a?(Pokemon)
        self.play_cry_from_pokemon(pkmn, volume, pitch)
      else
        self.play_cry_from_species(pkmn, nil, volume, pitch)
      end
    end

    def self.cry_length(species, form = 0, pitch = 100)
      return 0 if !species || pitch <= 0
      pitch = pitch.to_f / 100
      ret = 0.0
      if species.is_a?(Pokemon)
        if !species.egg?
          filename = pbResolveAudioSE(GameData::Species.cry_filename_from_pokemon(species))
          ret = getPlayTime(filename) if filename
        end
      else
        filename = pbResolveAudioSE(GameData::Species.cry_filename(species, form))
        ret = getPlayTime(filename) if filename
      end
      ret /= pitch # Sound played at a lower pitch lasts longer
      return (ret * Graphics.frame_rate).ceil + 4 # 4 provides a buffer between sounds
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbLoadSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
  Deprecation.warn_method("pbLoadSpeciesBitmap", "v20", "GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)")
  return GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
end

# @deprecated This alias is slated to be removed in v20.
def pbLoadPokemonBitmap(pkmn, back = false)
  Deprecation.warn_method("pbLoadPokemonBitmap", "v20", "GameData::Species.sprite_bitmap_from_pokemon(pkmn)")
  return GameData::Species.sprite_bitmap_from_pokemon(pkmn, back)
end

# @deprecated This alias is slated to be removed in v20.
def pbLoadPokemonBitmapSpecies(pkmn, species, back = false)
  Deprecation.warn_method("pbLoadPokemonBitmapSpecies", "v20", "GameData::Species.sprite_bitmap_from_pokemon(pkmn, back, species)")
  return GameData::Species.sprite_bitmap_from_pokemon(pkmn, back, species)
end

# @deprecated This alias is slated to be removed in v20.
def pbPokemonIconFile(pkmn)
  Deprecation.warn_method("pbPokemonIconFile", "v20", "GameData::Species.icon_filename_from_pokemon(pkmn)")
  return GameData::Species.icon_filename_from_pokemon(pkmn)
end

# @deprecated This alias is slated to be removed in v20.
def pbLoadPokemonIcon(pkmn)
  Deprecation.warn_method("pbLoadPokemonIcon", "v20", "GameData::Species.icon_bitmap_from_pokemon(pkmn)")
  return GameData::Species.icon_bitmap_from_pokemon(pkmn)
end

# @deprecated This alias is slated to be removed in v20.
def pbPokemonFootprintFile(species, form = 0)
  Deprecation.warn_method("pbPokemonFootprintFile", "v20", "GameData::Species.footprint_filename(species, form)")
  return GameData::Species.footprint_filename(species, form)
end

# @deprecated This alias is slated to be removed in v20.
def pbCheckPokemonShadowBitmapFiles(species, form = 0)
  Deprecation.warn_method("pbCheckPokemonShadowBitmapFiles", "v20", "GameData::Species.shadow_filename(species, form)")
  return GameData::Species.shadow_filename(species, form)
end

# @deprecated This alias is slated to be removed in v20.
def pbLoadPokemonShadowBitmap(pkmn)
  Deprecation.warn_method("pbLoadPokemonShadowBitmap", "v20", "GameData::Species.shadow_bitmap_from_pokemon(pkmn)")
  return GameData::Species.shadow_bitmap_from_pokemon(pkmn)
end

# @deprecated This alias is slated to be removed in v20.
def pbCryFile(species, form = 0)
  if species.is_a?(Pokemon)
    Deprecation.warn_method("pbCryFile", "v20", "GameData::Species.cry_filename_from_pokemon(pkmn)")
    return GameData::Species.cry_filename_from_pokemon(species)
  end
  Deprecation.warn_method("pbCryFile", "v20", "GameData::Species.cry_filename(species, form)")
  return GameData::Species.cry_filename(species, form)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayCry(pkmn, volume = 90, pitch = nil)
  Deprecation.warn_method("pbPlayCry", "v20", "GameData::Species.play_cry(pkmn)")
  GameData::Species.play_cry(pkmn, volume, pitch)
end

def play_cry(species, volume = 90, pitch = 100)
  echoln species
  GameData::Species.play_cry_from_species(species, 0, volume, pitch)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayCrySpecies(species, form = 0, volume = 90, pitch = nil)
  Deprecation.warn_method("pbPlayCrySpecies", "v20", "Pokemon.play_cry(species, form)")
  Pokemon.play_cry(species, form, volume, pitch)
end

# @deprecated This alias is slated to be removed in v20.
def pbPlayCryPokemon(pkmn, volume = 90, pitch = nil)
  Deprecation.warn_method("pbPlayCryPokemon", "v20", "pkmn.play_cry")
  pkmn.play_cry(volume, pitch)
end

# @deprecated This alias is slated to be removed in v20.
def pbCryFrameLength(species, form = 0, pitch = 100)
  Deprecation.warn_method("pbCryFrameLength", "v20", "GameData::Species.cry_length(species, form)")
  return GameData::Species.cry_length(species, form, pitch)
end
