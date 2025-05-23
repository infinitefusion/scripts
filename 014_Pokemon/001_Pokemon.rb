#===============================================================================
# Instances of this class are individual Pokémon.
# The player's party Pokémon are stored in the array $Trainer.party.
#===============================================================================
class Pokemon
  attr_accessor :spriteform_body
  attr_accessor :spriteform_head

  # @return [Symbol] this Pokémon's species
  attr_reader :species
  # If defined, this Pokémon's form will be this value even if a MultipleForms
  # handler tries to say otherwise.
  # @return [Integer, nil] this Pokémon's formspriteform
  attr_accessor :forced_form
  # If defined, is the time (in Integer form) when this Pokémon's form was set.
  # @return [Integer, nil] the time this Pokémon's form was set
  attr_accessor :time_form_set
  # @return [Integer] the current experience points
  attr_reader :exp

  attr_accessor :exp_when_fused_head
  attr_accessor :exp_when_fused_body
  attr_accessor :exp_gained_since_fused

  attr_accessor :hat
  attr_accessor :hat_x
  attr_accessor :hat_y

  # @return [Integer] the number of steps until this Pokémon hatches, 0 if this Pokémon is not an egg
  attr_accessor :steps_to_hatch
  # @return [Integer] the current HP
  attr_reader :hp
  # @return [Symbol] this Pokémon's current status (see GameData::Status)
  attr_reader :status
  # @return [Integer] sleep count / toxic flag / 0:
  #   sleep (number of rounds before waking up), toxic (0 = regular poison, 1 = toxic)
  attr_accessor :statusCount
  # This Pokémon's shininess (true, false, nil). Is recalculated if made nil.
  # @param value [Boolean, nil] whether this Pokémon is shiny
  #attr_writer :shiny
  attr_accessor :glitter
  attr_accessor :head_shiny
  attr_accessor :body_shiny
  attr_accessor :debug_shiny
  attr_accessor :natural_shiny

  # The index of this Pokémon's ability (0, 1 are natural abilities, 2+ are
  # hidden abilities)as defined for its species/form. An ability may not be
  # defined at this index. Is recalculated (as 0 or 1) if made nil.
  # @param value [Integer, nil] forced ability index (nil if none is set)
  attr_writer :ability_index
  attr_accessor :body_original_ability_index
  attr_accessor :head_original_ability_index

  # @return [Array<Pokemon::Move>] the moves known by this Pokémon
  attr_accessor :moves

  # @return [Array<Symbol>] All the move (ids) ever learned by this Pokémon
  attr_accessor :learned_moves

  # @return [Array<Integer>] the IDs of moves known by this Pokémon when it was obtained
  attr_accessor :first_moves
  # @return [Array<Symbol>] an array of ribbons owned by this Pokémon
  attr_accessor :ribbons
  # @return [Integer] contest stats
  attr_accessor :cool, :beauty, :cute, :smart, :tough, :sheen
  # @return [Integer] the Pokérus strain and infection time
  attr_accessor :pokerus
  # @return [Integer] this Pokémon's current happiness (an integer between 0 and 255)
  attr_accessor :happiness
  # @return [Symbol] the item ID of the Poké Ball this Pokémon is in
  attr_accessor :poke_ball
  # @return [Integer] this Pokémon's markings, one bit per marking
  attr_accessor :markings
  # @return [Hash<Integer>] a hash of IV values for HP, Atk, Def, Speed, Sp. Atk and Sp. Def
  attr_accessor :iv
  # An array of booleans indicating whether a stat is made to have maximum IVs
  # (for Hyper Training). Set like @ivMaxed[:ATTACK] = true
  # @return [Hash<Boolean>] a hash of booleans that max each IV value
  attr_accessor :ivMaxed
  # @return [Hash<Integer>] this Pokémon's effort values
  attr_accessor :ev
  # @return [Integer] calculated stats
  attr_reader :totalhp, :attack, :defense, :spatk, :spdef, :speed
  # @return [Owner] this Pokémon's owner
  attr_reader :owner
  # @return [Integer] the manner this Pokémon was obtained:
  #   0 (met), 1 (as egg), 2 (traded), 4 (fateful encounter)
  attr_accessor :obtain_method
  # @return [Integer] the ID of the map this Pokémon was obtained in
  attr_accessor :obtain_map
  # Describes the manner this Pokémon was obtained. If left undefined,
  # the obtain map's name is used.
  # @return [String] the obtain text
  attr_accessor :obtain_text
  # @return [Integer] the level of this Pokémon when it was obtained
  attr_accessor :obtain_level
  # If this Pokémon hatched from an egg, returns the map ID where the hatching happened.
  # Otherwise returns 0.
  # @return [Integer] the map ID where egg was hatched (0 by default)
  attr_accessor :hatched_map
  # Another Pokémon which has been fused with this Pokémon (or nil if there is none).
  # Currently only used by Kyurem, to record a fused Reshiram or Zekrom.
  # @return [Pokemon, nil] the Pokémon fused into this one (nil if there is none)
  attr_accessor :fused
  # @return [Integer] this Pokémon's personal ID
  attr_accessor :personalID

  attr_accessor :hiddenPowerType

  attr_accessor :sprite_scale #the size attribute for scaling the sprite (used only for gourgeist/pumpkaboo)
  attr_accessor :size_category #the size attribute for scaling the sprite (used only for gourgeist/pumpkaboo)

  attr_accessor :force_disobey

  # Max total IVs
  IV_STAT_LIMIT = 31
  # Max total EVs
  EV_LIMIT = 510
  # Max EVs that a single stat can have
  EV_STAT_LIMIT = 252
  # Maximum length a Pokémon's nickname can be
  MAX_NAME_SIZE = 16
  # Maximum number of moves a Pokémon can know at once
  MAX_MOVES = 4

  S_CHANCE_VALIDATOR = 16

  def print_all_attributes
    echoln("Spriteform Body: #{@spriteform_body}")
    echoln("Spriteform Head: #{@spriteform_head}")
    echoln("Species: #{@species}")
    echoln("Forced Form: #{@forced_form}")
    echoln("Time Form Set: #{@time_form_set}")
    echoln("Experience: #{@exp}")
    echoln("EXP When Fused Head: #{@exp_when_fused_head}")
    echoln("EXP When Fused Body: #{@exp_when_fused_body}")
    echoln("EXP Gained Since Fused: #{@exp_gained_since_fused}")
    echoln("Hat: #{@hat}")
    echoln("Hat X: #{@hat_x}")
    echoln("Hat Y: #{@hat_y}")
    echoln("Steps to Hatch: #{@steps_to_hatch}")
    echoln("HP: #{@hp}")
    echoln("Status: #{@status}")
    echoln("Status Count: #{@statusCount}")
    echoln("Glitter: #{@glitter}")
    echoln("Head Shiny: #{@head_shiny}")
    echoln("Body Shiny: #{@body_shiny}")
    echoln("Debug Shiny: #{@debug_shiny}")
    echoln("Natural Shiny: #{@natural_shiny}")

    echoln("Calculated ability: #{@ability}")
    echoln("Abilities hash: #{getAbilityList()}")

    echoln("Ability Index: #{@ability_index}")
    echoln("Body Original Ability Index: #{@body_original_ability_index}")
    echoln("Head Original Ability Index: #{@head_original_ability_index}")

    move1, move2, move3, move4 = "", "", "", ""

    move1 = @moves[0].id if @moves[0]
    move2 = @moves[1].id if @moves[1]
    move3 = @moves[2].id if @moves[2]
    move4 = @moves[3].id if @moves[3]

    echoln("Moves: #{move1} #{move2} #{move3} #{move4}")
    echoln("First Moves: #{@first_moves}")
    echoln("Ribbons: #{@ribbons}")
    echoln("Cool: #{@cool}, Beauty: #{@beauty}, Cute: #{@cute}, Smart: #{@smart}, Tough: #{@tough}, Sheen: #{@sheen}")
    echoln("Pokerus: #{@pokerus}")
    echoln("Happiness: #{@happiness}")
    echoln("Poke Ball: #{@poke_ball}")
    echoln("Markings: #{@markings}")
    echoln("IV: #{@iv}")
    echoln("IV Maxed: #{@ivMaxed}")
    echoln("EV: #{@ev}")
    echoln("Total HP: #{@totalhp}, Attack: #{@attack}, Defense: #{@defense}, Sp. Attack: #{@spatk}, Sp. Defense: #{@spdef}, Speed: #{@speed}")
    echoln("Owner: #{@owner}")
    echoln("Obtain Method: #{@obtain_method}")
    echoln("Obtain Map: #{@obtain_map}")
    echoln("Obtain Text: #{@obtain_text}")
    echoln("Obtain Level: #{@obtain_level}")
    echoln("Hatched Map: #{@hatched_map}")
    echoln("Fused: #{@fused}")
    echoln("Personal ID: #{@personalID}")
    echoln("Hidden Power Type: #{@hiddenPowerType}")
    echoln("Scale: #{sprite_scale}")

    # Add other attribute print statements here
  end

  def self.play_cry(species, form = 0, volume = 90, pitch = 100)
    GameData::Species.play_cry_from_species(species, form, volume, pitch)
  end

  def play_cry(volume = 90, pitch = nil)
    GameData::Species.play_cry_from_pokemon(self, volume, pitch)
  end

  def inspect
    str = super.chop
    str << format(' %s Lv.%s>', @species, @level.to_s || '???')
    return str
  end

  def species_data
    @species_data = GameData::Species.get(@species)
    return @species_data
  end

  def id_number
    return species_data.id_number
  end

  #=============================================================================
  # Species and form
  #=============================================================================
  def hiddenPower=(type)
    @hiddenPowerType = type
  end

  # Changes the Pokémon's species and re-calculates its statistics.
  # @param species_id [Integer] id of the species to change this Pokémon to
  def species=(species_id)
    new_species_data = GameData::Species.get(species_id)
    return if @species == new_species_data.species
    @species = new_species_data.species
    @form = new_species_data.form if new_species_data.form != 0
    @forced_form = nil
    @level = nil # In case growth rate is different for the new species
    @ability = nil
    calc_stats
  end

  def sprite_scale()
    @sprite_scale = 1 if !@sprite_scale
    return @sprite_scale
  end

  def sprite_scale=(scale)
    @sprite_scale = scale
  end


  def size_category()
    @size_category = :AVERAGE if !@size_category
    return @size_category
  end

  def size_category=(category)
    @size_category = category
  end
  # @param check_species [Integer, Symbol, String] id of the species to check for
  # @return [Boolean] whether this Pokémon is of the specified species
  def isSpecies?(check_species)
    return @species == check_species || (GameData::Species.exists?(check_species) &&
      @species == GameData::Species.get(check_species).species)
  end


  def hasBodyOf?(check_species)
    if !self.isFusion?
      return isSpecies?(check_species)
    end
    bodySpecies = getBodyID(species)
    checkSpeciesId = getID(nil, check_species)
    return bodySpecies == checkSpeciesId
  end

  def hasHeadOf?(check_species)
    if !self.isFusion?
      return isSpecies?(check_species)
    end
    headSpecies = getHeadID(species)
    checkSpeciesId = getID(nil, check_species)
    return headSpecies == checkSpeciesId
  end

  def head_id()
    return get_head_id_from_symbol(@species)
  end

  def body_id()
    return get_body_id_from_symbol(@species)
  end

  def shiny=(value)
    @shiny = value
    if value && Settings::SHINY_POKEMON_CHANCE != S_CHANCE_VALIDATOR
      @debug_shiny = true
    end
  end

  def naturalShiny?
    return @natural_shiny
  end

  def debugShiny?
    return !@natural_shiny || @debug_shiny
  end

  def bodyShiny?
    return @body_shiny
  end

  def headShiny?
    return @head_shiny
  end


  def isFusionOf(check_species)
    return hasBodyOf?(check_species) || hasHeadOf?(check_species)
  end


  def dexNum
    return species_data.id_number
  end

  def isSelfFusion?
    return isFusion? && getHeadID(species) == getBodyID(species)
  end

  def isFusion?
    return species_data.id_number > NB_POKEMON && !self.isTripleFusion?
  end

  def isTripleFusion?
    return species_data.id_number >= Settings::ZAPMOLCUNO_NB
  end

  def form
    return @forced_form if !@forced_form.nil?
    return @form if $game_temp.in_battle
    calc_form = MultipleForms.call("getForm", self)
    self.form = calc_form if calc_form != nil && calc_form != @form
    return @form
  end

  def changeFormSpecies(oldForm, newForm)

    is_already_old_form = self.isFusionOf(oldForm) #A 466
    is_already_new_form = self.isFusionOf(newForm) #P

    #reverse the fusion if it's a meloA and meloP fusion
    # There's probably a smarter way to do this but laziness lol
    if is_already_old_form && is_already_new_form
      body_id = self.species_data.get_body_species()
      body_species = GameData::Species.get(body_id)

      if body_species == oldForm
        changeSpeciesSpecific(self, getFusedPokemonIdFromSymbols(newForm, oldForm))
      else
        changeSpeciesSpecific(self, getFusedPokemonIdFromSymbols(oldForm, newForm))
      end
    else
      echoln "changing species...."
      changeSpecies(self, oldForm, newForm) if is_already_old_form
      changeSpecies(self, newForm, oldForm) if is_already_new_form
    end

    calc_stats
  end

  def changeSpecies(pokemon, speciesToReplace, newSpecies)
    if pokemon.isFusion?()
      replaceFusionSpecies(pokemon, speciesToReplace, newSpecies)
    else
      changeSpeciesSpecific(pokemon, newSpecies)
    end
    $Trainer.pokedex.set_seen(pokemon.species)
    $Trainer.pokedex.set_owned(pokemon.species)
  end

  def form_simple
    return @forced_form || @form
  end

  def form=(value)
    # oldForm = @form
    # @form = value
    # @ability = nil
    # MultipleForms.call("onSetForm", self, value, oldForm)
    # calc_stats
    # $Trainer.pokedex.register(self)
  end

  # The same as def form=, but yields to a given block in the middle so that a
  # message about the form changing can be shown before calling "onSetForm"
  # which may have its own messages, e.g. learning a move.
  def setForm(value)
    oldForm = @form
    @form = value
    @ability = nil
    yield if block_given?
    MultipleForms.call("onSetForm", self, value, oldForm)
    calc_stats
    $Trainer.pokedex.register(self)
  end

  def form_simple=(value)
    @form = value
    calc_stats
  end

  #=============================================================================
  # Level
  #=============================================================================

  # @return [Integer] this Pokémon's level
  def level
    @level = growth_rate.level_from_exp(@exp) if !@level
    return @level
  end

  # Sets this Pokémon's level. The given level must be between 1 and the
  # maximum level (defined in {GameData::GrowthRate}).
  # @param value [Integer] new level (between 1 and the maximum level)
  def level=(value)
    if value < 1 || value > GameData::GrowthRate.max_level
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.", value))
    end
    @exp = growth_rate.minimum_exp_for_level(value)
    @level = value
  end

  # Sets this Pokémon's Exp. Points.
  # @param value [Integer] new experience points
  def exp=(value)
    @exp = value
    @level = nil
  end

  # @return [Boolean] whether this Pokémon is an egg
  def egg?
    return @steps_to_hatch > 0
  end

  # @return [GameData::GrowthRate] this Pokémon's growth rate
  def growth_rate
    return GameData::GrowthRate.get(species_data.growth_rate)
  end

  # @return [Integer] this Pokémon's base Experience value
  def base_exp
    return species_data.base_exp
  end

  # @return [Float] a number between 0 and 1 indicating how much of the current level's
  #   Exp this Pokémon has
  def exp_fraction
    lvl = self.level
    return 0.0 if lvl >= GameData::GrowthRate.max_level
    g_rate = growth_rate
    start_exp = g_rate.minimum_exp_for_level(lvl)
    end_exp = g_rate.minimum_exp_for_level(lvl + 1)
    return (@exp - start_exp).to_f / (end_exp - start_exp)
  end

  #=============================================================================
  # Status
  #=============================================================================

  # Sets the Pokémon's health.
  # @param value [Integer] new HP value
  def hp=(value)
    @hp = value.clamp(0, @totalhp)
    heal_status if @hp == 0
    checkHPRelatedFormChange()
  end

  # Sets this Pokémon's status. See {GameData::Status} for all possible status effects.
  # @param value [Integer, Symbol, String] status to set
  def status=(value)
    return if !able?
    new_status = GameData::Status.try_get(value)
    if !new_status
      raise ArgumentError, _INTL('Attempted to set {1} as Pokémon status', value.class.name)
    end
    @status = new_status.id
  end

  # @return [Boolean] whether the Pokémon is not fainted and not an egg
  def able?
    return !egg? && @hp > 0
  end

  # @return [Boolean] whether the Pokémon is fainted
  def fainted?
    return !egg? && @hp <= 0
  end

  # Heals all HP of this Pokémon.
  def heal_HP
    return if egg?
    @hp = @totalhp
    checkHPRelatedFormChange()
  end

  # Heals the status problem of this Pokémon.
  def heal_status
    return if egg?
    @status = :NONE
    @statusCount = 0
  end

  # Restores all PP of this Pokémon. If a move index is given, restores the PP
  # of the move in that index.
  # @param move_index [Integer] index of the move to heal (-1 if all moves
  #   should be healed)
  def heal_PP(move_index = -1)
    return if egg?
    if move_index >= 0
      @moves[move_index].pp = @moves[move_index].total_pp
    else
      @moves.each { |m| m.pp = m.total_pp }
    end
  end

  # Heals all HP, PP, and status problems of this Pokémon.
  def heal
    return if egg?
    heal_HP
    heal_status
    heal_PP
  end

  #=============================================================================
  # Types
  #=============================================================================

  # @return [Symbol] this Pokémon's first type
  def type1
    if @ability == :MULTITYPE && species_data.type1 == :NORMAL
      return getHeldPlateType()
    end
    return @type1 if @type1
    return species_data.type1
  end

  # @return [Symbol] this Pokémon's second type, or the first type if none is defined
  def type2
    if @ability == :MULTITYPE && species_data.type2 == :NORMAL
      return getHeldPlateType()
    end
    sp_data = species_data
    return sp_data.type2 || sp_data.type1
  end

  def type1=(value)
    @type1 = value
  end

  def type2=(value)
    @type2 = value
  end

  # @return [Array<Symbol>] an array of this Pokémon's types
  def types
    sp_data = species_data
    ret = [sp_data.type1]
    ret.push(sp_data.type2) if sp_data.type2 && sp_data.type2 != sp_data.type1
    return ret
  end

  # @param type [Symbol, String, Integer] type to check
  # @return [Boolean] whether this Pokémon has the specified type
  def hasType?(type)
    type = GameData::Type.get(type).id
    return self.types.include?(type)
  end

  def getHeldPlateType()
    return getArceusPlateType(@item)
  end

  #=============================================================================
  # Gender
  #=============================================================================

  # @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
  def gender
    if !@gender
      gender_ratio = species_data.gender_ratio
      case gender_ratio
      when :AlwaysMale then
        @gender = 0
      when :AlwaysFemale then
        @gender = 1
      when :Genderless then
        @gender = 2
      else
        female_chance = GameData::GenderRatio.get(gender_ratio).female_chance
        @gender = ((@personalID & 0xFF) < female_chance) ? 1 : 0
      end
    end
    return @gender
  end

  # Sets this Pokémon's gender to a particular gender (if possible).
  # @param value [0, 1] new gender (0 = male, 1 = female)
  def gender=(value)
    return if singleGendered?
    @gender = value if value.nil? || value == 0 || value == 1
  end

  # Makes this Pokémon male.
  def makeMale
    @gender = 0
  end

  # Makes this Pokémon female.
  def makeFemale
    @gender = 1
  end

  # @return [Boolean] whether this Pokémon is male
  def male?
    return self.gender == 0;
  end

  # @return [Boolean] whether this Pokémon is female
  def female?
    return self.gender == 1;
  end

  # @return [Boolean] whether this Pokémon is genderless
  def genderless?
    return self.gender == 2;
  end

  # @return [Boolean] whether this Pokémon species is restricted to only ever being one
  #   gender (or genderless)
  def singleGendered?
    gender_ratio = species_data.gender_ratio
    return [:AlwaysMale, :AlwaysFemale, :Genderless].include?(gender_ratio)
  end

  #=============================================================================
  # Shininess
  #=============================================================================

  # @return [Boolean] whether this Pokémon is shiny (differently colored)
  def shiny?
    if @shiny.nil?
      a = @personalID ^ @owner.id
      b = a & 0xFFFF
      c = (a >> 16) & 0xFFFF
      d = b ^ c
      is_shiny = d < Settings::SHINY_POKEMON_CHANCE
      if is_shiny
        @shiny = true
        @natural_shiny = true
      end

    end
    if @shiny && Settings::SHINY_POKEMON_CHANCE != S_CHANCE_VALIDATOR
      @debug_shiny = true
      @natural_shiny = false
    end
    return @shiny
  end

  #=============================================================================
  # Ability
  #=============================================================================

  # @return [Integer] the index of this Pokémon's ability
  def ability_index
    @ability_index = (@personalID & 1) if !@ability_index
    return @ability_index
  end

  def forced_ability
    return @ability
  end

  # @return [GameData::Ability, nil] an Ability object corresponding to this Pokémon's ability
  def ability
    return GameData::Ability.try_get(ability_id)
  end

  # @return [Symbol, nil] the ability symbol of this Pokémon's ability
  def ability_id
    if !@ability
      sp_data = species_data
      abil_index = ability_index
      if abil_index >= 2 # Hidden ability
        @ability = sp_data.hidden_abilities[abil_index - 2]
        abil_index = (@personalID & 1) if !@ability
      end
      if !@ability # Natural ability or no hidden ability defined
        @ability = sp_data.abilities[abil_index] || sp_data.abilities[0]
      end
    end
    return @ability
  end

  def ability=(value)
    return if value && !GameData::Ability.exists?(value)
    @ability = (value) ? GameData::Ability.get(value).id : value
  end

  # Returns whether this Pokémon has a particular ability. If no value
  # is given, returns whether this Pokémon has an ability set.
  # @param check_ability [Symbol, GameData::Ability, Integer, nil] ability ID to check
  # @return [Boolean] whether this Pokémon has a particular ability or
  #   an ability at all
  def hasAbility?(check_ability = nil)
    current_ability = self.ability
    return !current_ability.nil? if check_ability.nil?
    return current_ability == check_ability
  end

  # @return [Boolean] whether this Pokémon has a hidden ability
  def hasHiddenAbility?
    return ability_index >= 2
  end

  # @return [Array<Array<Symbol,Integer>>] the abilities this Pokémon can have,
  #   where every element is [ability ID, ability index]
  def getAbilityList
    ret = []
    sp_data = species_data
    sp_data.abilities.each_with_index { |a, i| ret.push([a, i]) if a }
    sp_data.hidden_abilities.each_with_index { |a, i| ret.push([a, i + 2]) if a }
    return ret
  end

  #=============================================================================
  # Nature
  #=============================================================================

  # @return [GameData::Nature, nil] a Nature object corresponding to this Pokémon's nature
  def nature
    @nature = GameData::Nature.get(@personalID % (GameData::Nature::DATA.keys.length / 2)).id if !@nature
    return GameData::Nature.try_get(@nature)
  end

  def nature_id
    return @nature
  end

  # Sets this Pokémon's nature to a particular nature.
  # @param value [Symbol, String, Integer, nil] nature to change to
  def nature=(value)
    return if value && !GameData::Nature.exists?(value)
    @nature = (value) ? GameData::Nature.get(value).id : value
    calc_stats if !@nature_for_stats
  end

  # Returns the calculated nature, taking into account things that change its
  # stat-altering effect (i.e. Gen 8 mints). Only used for calculating stats.
  # @return [GameData::Nature, nil] this Pokémon's calculated nature
  def nature_for_stats
    return GameData::Nature.try_get(@nature_for_stats) if @nature_for_stats
    return self.nature
  end

  def nature_for_stats_id
    return @nature_for_stats
  end

  # If defined, this Pokémon's nature is considered to be this when calculating stats.
  # @param value [Integer, nil] ID of the nature to use for calculating stats
  def nature_for_stats=(value)
    return if value && !GameData::Nature.exists?(value)
    @nature_for_stats = (value) ? GameData::Nature.get(value).id : value
    calc_stats
  end

  # Returns whether this Pokémon has a particular nature. If no value is given,
  # returns whether this Pokémon has a nature set.
  # @param check_nature [Integer] nature ID to check
  # @return [Boolean] whether this Pokémon has a particular nature or a nature
  #   at all
  def hasNature?(check_nature = nil)
    return !@nature_id.nil? if check_nature.nil?
    return self.nature == check_nature
  end

  #=============================================================================
  # Items
  #=============================================================================

  # @return [GameData::Item, nil] an Item object corresponding to this Pokémon's item
  def item
    return GameData::Item.try_get(@item)
  end

  def item_id
    return @item
  end

  # Gives an item to this Pokémon to hold.
  # @param value [Symbol, GameData::Item, Integer, nil] ID of the item to give
  #   to this Pokémon
  def item=(value)
    return if value && !GameData::Item.exists?(value)
    @item = (value) ? GameData::Item.get(value).id : value
  end

  # Returns whether this Pokémon is holding an item. If an item id is passed,
  # returns whether the Pokémon is holding that item.
  # @param check_item [Symbol, GameData::Item, Integer] item ID to check
  # @return [Boolean] whether the Pokémon is holding the specified item or
  #   an item at all
  def hasItem?(check_item = nil)
    return !@item.nil? if check_item.nil?
    held_item = self.item
    return held_item && held_item == check_item
  end

  # @return [Array<Symbol>] the items this species can be found holding in the wild
  def wildHoldItems
    sp_data = species_data
    return [sp_data.wild_item_common, sp_data.wild_item_uncommon, sp_data.wild_item_rare]
  end

  # @return [Mail, nil] mail held by this Pokémon (nil if there is none)
  def mail
    @mail = nil if @mail && (!@mail.item || !hasItem?(@mail.item))
    return @mail
  end

  # If mail is a Mail object, gives that mail to this Pokémon. If nil is given,
  # removes the held mail.
  # @param mail [Mail, nil] mail to be held by this Pokémon
  def mail=(mail)
    if !mail.nil? && !mail.is_a?(Mail)
      raise ArgumentError, _INTL('Invalid value {1} given', mail.inspect)
    end
    @mail = mail
  end

  #=============================================================================
  # Moves
  #=============================================================================

  # @return [Integer] the number of moves known by the Pokémon
  def numMoves
    return @moves.length
  end

  # @param move_id [Symbol, String, Integer] ID of the move to check
  # @return [Boolean] whether the Pokémon knows the given move
  def hasMove?(move_id)
    move_data = GameData::Move.try_get(move_id)
    return false if !move_data
    return @moves.any? { |m| m.id == move_data.id }
  end

  # Returns the list of moves this Pokémon can learn by levelling up.
  # @return [Array<Array<Integer,Symbol>>] this Pokémon's move list, where every element is [level, move ID]
  def getMoveList
    return species_data.moves
  end

  # Sets this Pokémon's movelist to the default movelist it originally had.
  def reset_moves
    this_level = self.level
    # Find all level-up moves that self could have learned
    moveset = self.getMoveList
    knowable_moves = []
    moveset.each { |m| knowable_moves.push(m[1]) if m[0] <= this_level }
    # Remove duplicates (retaining the latest copy of each move)
    knowable_moves = knowable_moves.reverse
    knowable_moves |= []
    knowable_moves = knowable_moves.reverse
    # Add all moves
    @moves.clear
    first_move_index = knowable_moves.length - MAX_MOVES
    first_move_index = 0 if first_move_index < 0
    for i in first_move_index...knowable_moves.length
      move = Pokemon::Move.new(knowable_moves[i])
      @moves.push(move)
      add_learned_move(move)
    end
  end

  def add_learned_move(move)
    @learned_moves = [] if !@learned_moves
    if move.is_a?(Symbol)
      @learned_moves << move unless @learned_moves.include?(move)
    else
      move_id = move.id
      if move_id
        @learned_moves << move_id unless @learned_moves.include?(move_id)
      end
    end
  end


  # Silently learns the given move. Will erase the first known move if it has to.
  # @param move_id [Symbol, String, Integer] ID of the move to learn
  def learn_move(move_id)
    move_data = GameData::Move.try_get(move_id)
    return if !move_data
    # Check if self already knows the move; if so, move it to the end of the array
    @moves.each_with_index do |m, i|
      next if m.id != move_data.id
      @moves.push(m)
      @moves.delete_at(i)
      return
    end
    move = Pokemon::Move.new(move_data.id)
    # Move is not already known; learn it
    @moves.push(move)
    # Delete the first known move if self now knows more moves than it should
    @moves.shift if numMoves > MAX_MOVES
    add_learned_move(move)
  end

  # Deletes the given move from the Pokémon.
  # @param move_id [Symbol, String, Integer] ID of the move to delete
  def forget_move(move_id)
    move_data = GameData::Move.try_get(move_id)
    return if !move_data
    add_learned_move(move_id)
    @moves.delete_if { |m| m.id == move_data.id }
  end

  # Deletes the move at the given index from the Pokémon.
  # @param index [Integer] index of the move to be deleted
  def forget_move_at_index(index)
    move_id = @moves[index].id
    add_learned_move(move_id)
    @moves.delete_at(index)
  end

  # Deletes all moves from the Pokémon.
  def forget_all_moves
    for move in @moves
      add_learned_move(move)
    end
    @moves.clear
  end

  # Copies currently known moves into a separate array, for Move Relearner.
  def record_first_moves
    clear_first_moves
    @moves.each { |m| @first_moves.push(m.id) }
  end

  # Adds a move to this Pokémon's first moves.
  # @param move_id [Symbol, String, Integer] ID of the move to add
  def add_first_move(move_id)
    move_data = GameData::Move.try_get(move_id)
    @first_moves.push(move_data.id) if move_data && !@first_moves.include?(move_data.id)
  end

  # Removes a move from this Pokémon's first moves.
  # @param move_id [Symbol, String, Integer] ID of the move to remove
  def remove_first_move(move_id)
    move_data = GameData::Move.try_get(move_id)
    @first_moves.delete(move_data.id) if move_data
  end

  # Clears this Pokémon's first moves.
  def clear_first_moves
    @first_moves.clear
  end

  # @param move_id [Symbol, String, Integer] ID of the move to check
  # @return [Boolean] whether the Pokémon is compatible with the given move
  def compatible_with_move?(move_id)
    move_data = GameData::Move.try_get(move_id)
    if isFusion?()
      head_species_id = getBasePokemonID(species, false)
      body_species_id = getBasePokemonID(species)
      head_species = GameData::Species.get(head_species_id)
      body_species = GameData::Species.get(body_species_id)
      return move_data && (pokemon_can_learn_move(head_species, move_data) || pokemon_can_learn_move(body_species, move_data))
    else
      return move_data && pokemon_can_learn_move(species_data, move_data)
    end
  end

  def pokemon_can_learn_move(species_data, move_data)
    moveset = species_data.moves.map { |pair| pair[1] }
    return species_data.tutor_moves.include?(move_data.id) ||
      species_data.moves.include?(move_data.id) ||  ##this is formatted as such [[1, :PECK],[etc.]] so it never finds anything when move_data is just the symbol. Leaving it there in case something depends on that for some reason.
      moveset.include?(move_data.id) ||
      species_data.egg_moves.include?(move_data.id)
  end

  def can_relearn_move?
    return false if egg? || shadowPokemon?
    this_level = self.level
    getMoveList.each { |m| return true if m[0] <= this_level && !hasMove?(m[1]) }
    @first_moves.each { |m| return true if !hasMove?(m) }
    return false
  end

  def has_egg_move?
    return false if egg? || shadowPokemon?
    baby = pbGetBabySpecies(self.species)
    moves = pbGetSpeciesEggMoves(baby)
    return true if moves.size >= 1
  end

  #=============================================================================
  # Ribbons
  #=============================================================================

  # @return [Integer] the number of ribbons this Pokémon has
  def numRibbons
    return @ribbons.length
  end

  # @param ribbon [Symbol, String, GameData::Ribbon, Integer] ribbon ID to check for
  # @return [Boolean] whether this Pokémon has the specified ribbon
  def hasRibbon?(ribbon)
    ribbon_data = GameData::Ribbon.try_get(ribbon)
    return ribbon_data && @ribbons.include?(ribbon_data.id)
  end

  # Gives a ribbon to this Pokémon.
  # @param ribbon [Symbol, String, GameData::Ribbon, Integer] ID of the ribbon to give
  def giveRibbon(ribbon)
    ribbon_data = GameData::Ribbon.try_get(ribbon)
    return if !ribbon_data || @ribbons.include?(ribbon_data.id)
    @ribbons.push(ribbon_data.id)
  end

  # Replaces one ribbon with the next one along, if possible. If none of the
  # given ribbons are owned, give the first one.
  # @return [Symbol, nil] ID of the ribbon that was gained
  def upgradeRibbon(*arg)
    for i in 0...arg.length - 1
      this_ribbon_data = GameData::Ribbon.try_get(i)
      next if !this_ribbon_data
      for j in 0...@ribbons.length
        next if @ribbons[j] != this_ribbon_data.id
        next_ribbon_data = GameData::Ribbon.try_get(arg[i + 1])
        next if !next_ribbon_data
        @ribbons[j] = next_ribbon_data.id
        return @ribbons[j]
      end
    end
    first_ribbon_data = GameData::Ribbon.try_get(arg[0])
    last_ribbon_data = GameData::Ribbon.try_get(arg[arg.length - 1])
    if first_ribbon_data && last_ribbon_data && !hasRibbon?(last_ribbon_data.id)
      giveRibbon(first_ribbon_data.id)
      return first_ribbon_data.id
    end
    return nil
  end

  # Removes the specified ribbon from this Pokémon.
  # @param ribbon [Symbol, String, GameData::Ribbon, Integer] ID of the ribbon to remove
  def takeRibbon(ribbon)
    ribbon_data = GameData::Ribbon.try_get(ribbon)
    return if !ribbon_data
    for i in 0...@ribbons.length
      next if @ribbons[i] != ribbon_data.id
      @ribbons[i] = nil
      @ribbons.compact!
      break
    end
  end

  # Removes all ribbons from this Pokémon.
  def clearAllRibbons
    @ribbons.clear
  end

  #=============================================================================
  # Pokérus
  #=============================================================================

  # @return [Integer] the Pokérus infection stage for this Pokémon
  def pokerusStrain
    return @pokerus / 16
  end

  # Returns the Pokérus infection stage for this Pokémon. The possible stages are
  # 0 (not infected), 1 (infected) and 2 (cured)
  # @return [0, 1, 2] current Pokérus infection stage
  def pokerusStage
    return 0 if @pokerus == 0
    return ((@pokerus % 16) == 0) ? 2 : 1
  end

  # Gives this Pokémon Pokérus (either the specified strain or a random one).
  # @param strain [Integer] Pokérus strain to give
  def givePokerus(strain = 0)
    return if self.pokerusStage == 2 # Can't re-infect a cured Pokémon
    strain = rand(1..16) if strain <= 0 || strain >= 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  # Resets the infection time for this Pokémon's Pokérus (even if cured).
  def resetPokerusTime
    return if @pokerus == 0
    strain = @pokerus % 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  # Reduces the time remaining for this Pokémon's Pokérus (if infected).
  def lowerPokerusCount
    return if self.pokerusStage != 1
    @pokerus -= 1
  end

  #=============================================================================
  # Ownership, obtained information
  #=============================================================================

  # Changes this Pokémon's owner.
  # @param new_owner [Owner] the owner to change to
  def owner=(new_owner)
    validate new_owner => Owner
    @owner = new_owner
  end

  # @param trainer [Player, NPCTrainer] the trainer to compare to the original trainer
  # @return [Boolean] whether the given trainer is not this Pokémon's original trainer
  def foreign?(trainer)
    return @owner.id != trainer.id# || @owner.name != trainer.name
  end

  def always_disobey(value)
    @force_disobey = value
  end

  # @return [Time] the time when this Pokémon was obtained
  def timeReceived
    return Time.at(@timeReceived)
  end

  # Sets the time when this Pokémon was obtained.
  # @param value [Integer, Time, #to_i] time in seconds since Unix epoch
  def timeReceived=(value)
    @timeReceived = value.to_i
  end

  # @return [Time] the time when this Pokémon hatched
  def timeEggHatched
    return (obtain_method == 1) ? Time.at(@timeEggHatched) : nil
  end

  # Sets the time when this Pokémon hatched.
  # @param value [Integer, Time, #to_i] time in seconds since Unix epoch
  def timeEggHatched=(value)
    @timeEggHatched = value.to_i
  end

  #=============================================================================
  # Other
  #=============================================================================

  # @return [String] the name of this Pokémon
  def name
    return (nicknamed?) ? @name : speciesName
  end

  # @param value [String] the nickname of this Pokémon
  def name=(value)
    value = nil if !value || value.empty? || value == speciesName
    @name = value
  end

  # @return [Boolean] whether this Pokémon has been nicknamed
  def nicknamed?
    return @name && !@name.empty?
  end

  # @return [String] the species name of this Pokémon
  def speciesName
    return species_data.name
  end

  # @return [Integer] the height of this Pokémon in metres
  def height
    return species_data.height/10
  end

  # @return [Integer] the weight of this Pokémon in kilograms
  def weight
    return species_data.weight/10
  end

  # @return [Hash<Integer>] the EV yield of this Pokémon (a hash with six key/value pairs)
  def evYield
    this_evs = species_data.evs
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = this_evs[s.id] }
    return ret
  end

  # Changes the happiness of this Pokémon depending on what happened to change it.
  # @param method [String] the happiness changing method (e.g. 'walking')
  def changeHappiness(method)
    gain = 0
    happiness_range = @happiness / 100
    case method
    when "walking"
      gain = [2, 2, 1][happiness_range]
    when "levelup"
      gain = [5, 4, 3][happiness_range]
    when "groom"
      gain = [10, 10, 4][happiness_range]
    when "evberry"
      gain = [10, 5, 2][happiness_range]
    when "vitamin"
      gain = [5, 3, 2][happiness_range]
    when "wing"
      gain = [3, 2, 1][happiness_range]
    when "machine", "battleitem"
      gain = [1, 1, 0][happiness_range]
    when "faint"
      gain = -1
    when "faintbad" # Fainted against an opponent that is 30+ levels higher
      gain = [-5, -5, -10][happiness_range]
    when "powder"
      gain = [-5, -5, -10][happiness_range]
    when "energyroot"
      gain = [-10, -10, -15][happiness_range]
    when "revivalherb"
      gain = [-15, -15, -20][happiness_range]
    else
      raise _INTL("Unknown happiness-changing method: {1}", method.to_s)
    end
    if gain > 0
      gain += 1 if @obtain_map == $game_map.map_id
      gain += 1 if @poke_ball == :LUXURYBALL
      gain = (gain * 1.5).floor if hasItem?(:SOOTHEBELL)
    end
    @happiness = (@happiness + gain).clamp(0, 255)
  end

  #=============================================================================
  # Evolution checks
  #=============================================================================
  # Checks whether this Pokemon can evolve because of levelling up.
  # @return [Symbol, nil] the ID of the species to evolve into
  def prompt_evolution_choice(body_evolution, head_evolution)
    current_body = @species_data.body_pokemon
    current_head = @species_data.head_pokemon

    choices = [
      #_INTL("Evolve both!"),
      _INTL("Evolve head!"),
      _INTL("Evolve body!"),
      _INTL("Don't evolve")
    ]
    choice = pbMessage(_INTL('Both halves of {1} are ready to evolve!', self.name), choices, 0)
    # if choice == 0  #EVOLVE BOTH
    #   newspecies = getFusionSpecies(body_evolution,head_evolution)
    if choice == 0 #EVOLVE HEAD
      newspecies = getFusionSpecies(current_body, head_evolution)
    elsif choice == 1 #EVOLVE BODY
      newspecies = getFusionSpecies(body_evolution, current_head)
    else
      newspecies = nil
    end
    return newspecies
  end

  def check_evolution_on_level_up(prompt_choice=true)
    if @species_data.is_a?(GameData::FusedSpecies)
      body = self.species_data.body_pokemon
      head = self.species_data.head_pokemon

      body_evolution = check_evolution_internal(@species_data.body_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
      head_evolution = check_evolution_internal(@species_data.head_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
      if body_evolution && head_evolution
        return prompt_evolution_choice(body_evolution, head_evolution) if prompt_choice
        return [body_evolution,head_evolution].sample
      end
    end

    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
      next (success) ? new_species : nil
    }

  end

  # Checks whether this Pokemon can evolve because of using an item on it.
  # @param item_used [Symbol, GameData::Item, nil] the item being used
  # @return [Symbol, nil] the ID of the species to evolve into
  def check_evolution_on_use_item(item_used)
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_use_item(pkmn, parameter, item_used)
      next (success) ? new_species : nil
    }
  end

  # Checks whether this Pokemon can evolve because of being traded.
  # @param other_pkmn [Pokemon] the other Pokémon involved in the trade
  # @return [Symbol, nil] the ID of the species to evolve into
  def check_evolution_on_trade(other_pkmn)
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_on_trade(pkmn, parameter, other_pkmn)
      next (success) ? new_species : nil
    }
  end

  # Called after this Pokémon evolves, to remove its held item (if the evolution
  # required it to have a held item) or duplicate this Pokémon (Shedinja only).
  # @param new_species [Pokemon] the species that this Pokémon evolved into
  def action_after_evolution(new_species)
    species_data.get_evolutions(true).each do |evo|
      # [new_species, method, parameter]
      break if GameData::Evolution.get(evo[1]).call_after_evolution(self, evo[0], evo[2], new_species)
    end
  end

  # The core method that performs evolution checks. Needs a block given to it,
  # which will provide either a GameData::Species ID (the species to evolve
  # into) or nil (keep checking).
  # @return [Symbol, nil] the ID of the species to evolve into
  def check_evolution_internal(species = nil)
    return nil if egg? || shadowPokemon?
    return nil if hasItem?(:EVERSTONE)
    return nil if hasAbility?(:BATTLEBOND)
    species = species_data if !species

    species.get_evolutions(true).each do |evo|
      # [new_species, method, parameter, boolean]
      next if evo[3] # Prevolution
      ret = yield self, evo[0], evo[1], evo[2] # pkmn, new_species, method, parameter
      return ret if ret
    end
    return nil
  end

  #=============================================================================
  # Stat calculations
  #=============================================================================
  def getBaseStatsFormException()
    if @species == :PUMPKABOO
      case @size_category
      when :SMALL
        return { :HP => 44, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 56}
      when :AVERAGE
        return nil
      when :LARGE
        return { :HP => 54, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 46}
      when :SUPER
        return { :HP => 59, :ATTACK => 66, :DEFENSE => 70, :SPECIAL_ATTACK => 44, :SPECIAL_DEFENSE => 55, :SPEED => 41}
      end
    end
    if @species == :GOURGEIST
      case @size_category
      when :SMALL
        return { :HP => 55, :ATTACK => 85, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 99}
      when :AVERAGE
        return nil
      when :LARGE
        return { :HP => 75, :ATTACK => 95, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 69}
      when :SUPER
        return { :HP => 85, :ATTACK => 100, :DEFENSE => 122, :SPECIAL_ATTACK => 58, :SPECIAL_DEFENSE => 75, :SPEED => 54}
      end
    end
    return nil
  end


  # @return [Hash<Integer>] this Pokémon's base stats, a hash with six key/value pairs
  def baseStats
    this_base_stats = species_data.base_stats
    base_stats_exception = getBaseStatsFormException()
    this_base_stats = base_stats_exception if base_stats_exception
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = this_base_stats[s.id] }
    return ret
  end

  # Returns this Pokémon's effective IVs, taking into account Hyper Training.
  # Only used for calculating stats.
  # @return [Hash<Integer>] hash containing this Pokémon's effective IVs
  def calcIV
    this_ivs = self.iv
    ret = {}
    GameData::Stat.each_main do |s|
      ret[s.id] = (@ivMaxed[s.id]) ? IV_STAT_LIMIT : this_ivs[s.id]
    end
    return ret
  end

  # @return [Integer] the maximum HP of this Pokémon
  def calcHP(base, level, iv, ev)
    return 1 if base == 1 # For Shedinja
    return ((base * 2 + iv + (ev / 4)) * level / 100).floor + level + 10
  end

  # @return [Integer] the specified stat of this Pokémon (not used for total HP)
  def calcStat(base, level, iv, ev, nat)
    return ((((base * 2 + iv + (ev / 4)) * level / 100).floor + 5) * nat / 100).floor
  end

  def adjust_level_for_base_stats_mode()
    nb_badges = $Trainer.badge_count
    this_level = ((nb_badges * Settings::NO_LEVEL_MODE_LEVEL_INCR) + Settings::NO_LEVEL_MODE_LEVEL_BASE).ceil
    if this_level > Settings::MAXIMUM_LEVEL
      this_level = Settings::MAXIMUM_LEVEL
    end
    return this_level
  end

  def adjustHPForWonderGuard(stats)
    return self.ability == :WONDERGUARD ? 1 : stats[:HP]
  end

  def checkHPRelatedFormChange()
    if @ability == :SHIELDSDOWN
      return if $game_temp.in_battle  #handled in battlers class in-battle
      if isFusionOf(:MINIOR_M)
        if @hp <= (@totalhp / 2)
          changeFormSpecies(:MINIOR_M, :MINIOR_C)
        end
      end
      if isFusionOf(:MINIOR_C)
        if @hp > (@totalhp / 2)
          changeFormSpecies(:MINIOR_C, :MINIOR_M)
        end
      end
    end
  end

  # Recalculates this Pokémon's stats.
  def calc_stats
    base_stats = self.baseStats
      this_level = self.level
    this_IV = self.calcIV

    if $game_switches[SWITCH_NO_LEVELS_MODE]
      this_level = adjust_level_for_base_stats_mode()
    end

    # Format stat multipliers due to nature
    nature_mod = {}
    GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
    this_nature = self.nature_for_stats
    if this_nature
      this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
    end
    # Calculate stats
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id])
      else
        stats[s.id] = calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id])
      end
    end
    hpDiff = @totalhp - @hp
    #@totalhp = stats[:HP]
    @totalhp = adjustHPForWonderGuard(stats)
    calculated_hp = @totalhp - hpDiff
    @hp = calculated_hp > 0 ? calculated_hp : 0
    @attack = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk = stats[:SPECIAL_ATTACK]
    @spdef = stats[:SPECIAL_DEFENSE]
    @speed = stats[:SPEED]
  end

  #=============================================================================
  # Pokémon creation
  #=============================================================================

  # Creates a copy of this Pokémon and returns it.
  # @return [Pokemon] a copy of this Pokémon
  def clone
    ret = super
    ret.iv = {}
    ret.ivMaxed = {}
    ret.ev = {}
    GameData::Stat.each_main do |s|
      ret.iv[s.id] = @iv[s.id]
      ret.ivMaxed[s.id] = @ivMaxed[s.id]
      ret.ev[s.id] = @ev[s.id]
    end
    ret.moves = []
    @moves.each_with_index { |m, i| ret.moves[i] = m.clone }
    ret.first_moves = @first_moves.clone
    ret.owner = @owner.clone
    ret.ribbons = @ribbons.clone
    return ret
  end

  # Creates a new Pokémon object.
  # @param species [Symbol, String, Integer] Pokémon species
  # @param level [Integer] Pokémon level
  # @param owner [Owner, Player, NPCTrainer] Pokémon owner (the player by default)
  # @param withMoves [TrueClass, FalseClass] whether the Pokémon should have moves
  # @param rechech_form [TrueClass, FalseClass] whether to auto-check the form
  def determine_scale
    return :AVERAGE if !@size_category
    size_roll = rand(100) # Random number between 0-99
    if @size_category == :SMALL
      return 0.75
    elsif @size_category == :AVERAGE
      return 1
    elsif @size_category == :LARGE
      return 1 + (1.0 /3) #"Large Size"
    elsif @size_category == :SUPER
      return 1 + (2.0 /3)      #"Super Size"
    end
    return 1
  end

  def determine_size_category
    return :AVERAGE if !(Kernel.isPartPokemon(self,:PUMPKABOO) || Kernel.isPartPokemon(self,:GOURGEIST))
    size_roll = rand(100) # Random number between 0-99
    if size_roll < 10
      return :SMALL
    elsif size_roll < 50
      return :AVERAGE
    elsif size_roll < 90
      return :LARGE
    else
      return :SUPER
    end
  end

  def initialize(species, level, owner = $Trainer, withMoves = true, recheck_form = true)
    @species_data = GameData::Species.get(species)
    @species = @species_data.species
    @form = @species_data.form
    @forced_form = nil
    @time_form_set = nil
    self.level = level
    @steps_to_hatch = 0
    heal_status
    @gender = nil
    @shiny = nil
    @ability_index = nil
    @ability2_index = nil

    @ability = nil
    @ability2 = nil

    @nature = nil
    @nature_for_stats = nil
    @item = nil
    @mail = nil
    @moves = []
    @learned_moves = []
    reset_moves if withMoves
    @first_moves = []
    @ribbons = []
    @cool = 0
    @beauty = 0
    @cute = 0
    @smart = 0
    @tough = 0
    @sheen = 0
    @pokerus = 0
    @name = nil
    @happiness = @species_data.happiness
    @poke_ball = :POKEBALL
    @markings = 0
    @iv = {}
    @ivMaxed = {}
    @ev = {}
    @hiddenPowerType = nil
    @glitter = nil
    GameData::Stat.each_main do |s|
      @iv[s.id] = rand(IV_STAT_LIMIT + 1)
      @ev[s.id] = 0
    end
    if owner.is_a?(Owner)
      @owner = owner
    elsif owner.is_a?(Player) || owner.is_a?(NPCTrainer)
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, '', 2, 2)
    end
    @obtain_method = 0 # Met
    @obtain_method = 4 if $game_switches && $game_switches[Settings::FATEFUL_ENCOUNTER_SWITCH]
    @obtain_map = ($game_map) ? $game_map.map_id : 0
    @obtain_text = nil
    @obtain_level = level
    @hatched_map = 0
    @timeReceived = Time.new.to_i
    @timeEggHatched = nil
    @fused = nil
    @personalID = rand(2 ** 16) | rand(2 ** 16) << 16
    @hp = 1
    @totalhp = 1
    @spriteform_body = nil
    @spriteform_head = nil

    @hat = nil
    @hat_x = 0
    @hat_y = 0
    @size_category = determine_size_category()
    @sprite_scale=determine_scale()
    calc_stats
    if @form == 0 && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end

  def totalIv()

  end
end
