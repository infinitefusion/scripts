# frozen_string_literal: true

class BattledTrainer
  TRAINER_CLASS_FAVORITE_TYPES =
    {
      AROMALADY:      [:GRASS, :FAIRY],
      BEAUTY:         [:FAIRY, :WATER, :NORMAL, :GRASS],
      BIKER:          [:POISON, :DARK],
      BIRDKEEPER:     [:FLYING, :NORMAL],
      BUGCATCHER:     [:BUG],
      BURGLAR:        [:FIRE, :DARK],
      CHANNELER:      [:GHOST, :PSYCHIC],
      CUEBALL:        [:FIGHTING],
      ENGINEER:       [:ELECTRIC, :STEEL],
      FISHERMAN:      [:WATER],
      GAMBLER:        [:NORMAL, :PSYCHIC],
      GENTLEMAN:      [:NORMAL, :STEEL],
      HIKER:          [:ROCK, :GROUND],
      JUGGLER:        [:PSYCHIC, :GHOST],
      LADY:           [:FAIRY, :NORMAL],
      PAINTER:        [:NORMAL, :PSYCHIC],
      POKEMANIAC:     [:DRAGON, :GROUND],
      POKEMONBREEDER: [:NORMAL, :GRASS],
      PROFESSOR:      [:NORMAL, :PSYCHIC],
      ROCKER:         [:ELECTRIC, :FIRE],
      RUINMANIAC:     [:GROUND, :ROCK],
      SAILOR:         [:WATER, :FIGHTING],
      SCIENTIST:      [:ELECTRIC, :STEEL, :POISON],
      SUPERNERD:      [:ELECTRIC, :PSYCHIC, :STEEL],
      TAMER:          [:NORMAL, :DARK],
      BLACKBELT:      [:FIGHTING],
      CRUSHGIRL:      [:FIGHTING],
      CAMPER:         [:BUG, :NORMAL, :GRASS],
      PICNICKER:      [:GRASS, :NORMAL],
      COOLTRAINER_M:  [:DRAGON, :STEEL, :FIRE],
      COOLTRAINER_F:  [:ICE, :PSYCHIC, :FAIRY],
      YOUNGSTER:      [:NORMAL, :BUG],
      LASS:           [:NORMAL, :FAIRY],
      POKEMONRANGER_M: [:GRASS, :GROUND],
      POKEMONRANGER_F: [:GRASS, :WATER],
      PSYCHIC_M:      [:PSYCHIC, :GHOST],
      PSYCHIC_F:      [:PSYCHIC, :FAIRY],
      SWIMMER_M:      [:WATER],
      SWIMMER_F:      [:WATER, :ICE],
      SWIMMER2_M:     [:WATER],
      SWIMMER2_F:     [:WATER],
      TUBER_M:        [:WATER],
      TUBER_F:        [:WATER],
      TUBER2_M:       [:WATER],
      TUBER2_F:       [:WATER],
      COOLCOUPLE:     [:FIRE, :ICE],
      CRUSHKIN:       [:FIGHTING],
      SISANDBRO:      [:WATER, :GROUND],
      TWINS:          [:FAIRY, :NORMAL],
      YOUNGCOUPLE:    [:NORMAL, :PSYCHIC],
      SOCIALITE:      [:FAIRY, :NORMAL],
      BUGCATCHER_F:   [:BUG],
      ROUGHNECK:      [:DARK, :FIGHTING],
      TEACHER:        [:PSYCHIC, :NORMAL],
      PRESCHOOLER_M:  [:NORMAL],
      PRESCHOOLER_F:  [:FAIRY, :NORMAL],
      HAUNTEDGIRL_YOUNG:  [:GHOST],
      HAUNTEDGIRL:        [:GHOST, :DARK],
      CLOWN:          [:PSYCHIC, :FAIRY],
      NURSE:          [:NORMAL, :FAIRY],
      WORKER:         [:STEEL, :GROUND],
      COOLTRAINER_M2: [:FIGHTING, :STEEL],
      COOLTRAINER_F2: [:PSYCHIC, :ICE],
      FARMER:         [:GRASS, :GROUND, :NORMAL],
      PYROMANIAC:     [:FIRE],
      KIMONOGIRL:     [:FAIRY, :PSYCHIC, :GHOST],
      SAGE:           [:PSYCHIC, :GHOST],
      PLAYER:         [:ICE, :FIGHTING],
      POLICE:         [:DARK, :FIGHTING],
      SKIER_F:        [:ICE],
      DELIVERYMAN:  [:NORMAL],
    }

  DELAY_BETWEEN_NPC_TRADES = 180 #In seconds (3 minutes)

  attr_accessor :trainerType
  attr_accessor :trainerName

  attr_accessor :currentTeam  #list of Pokemon. The game selects in this list for trade offers. They can increase levels & involve as you rebattle them.

  #trainers will randomly find items and add them to this list. When they have the :ITEM status, they will
  # give one of them at random.
  #Items equipped to the Pokemon traded by the player will end up in that list.
  #
  # If there is an evolution that the trainer can use on one of their Pokemon in that list, they will
  # instead use it to evolve their Pokemon.
  #
  #DNA Splicers/reversers can be used on their Pokemon if they have at least 2 unfused/1 fused
  #
  #Healing items that are in that list can be used by the trainer in rematches
  #
  attr_accessor :foundItems


  attr_accessor :nb_rematches

  #What the trainer currently wants to do
  # :IDLE -> Nothing. Normal postbattle dialogue
  # Should prompt the player to register the trainer in their phone.
  # Or maybe done automatically at the end of the battle?

  # :TRADE -> Trainer wants to trade one of its Pokémon with the player

  # :BATTLE -> Trainer wants to rebattle the player

  # :ITEM -> Trainer has an item they want to give the player
  attr_accessor :current_status
  attr_accessor :previous_status
  attr_accessor :previous_trade_timestamp

  attr_accessor :favorite_type
  attr_accessor :favorite_pokemon #Used for generating trade offers. Should be set from trainer.txt (todo)
  #If empty, then trade offers ask for a Pokemon of a type depending on the trainer's class

  attr_accessor :previous_random_events
  attr_accessor :has_pending_action
  attr_accessor :custom_appearance

  def initialize(trainerType,trainerName,trainerVersion)
    @trainerType = trainerType
    @trainerName = trainerName
    @currentTeam = loadOriginalTrainerTeam(trainerVersion)
    @foundItems = []
    @nb_rematches = 0
    @currentStatus = :IDLE
    @previous_status = :IDLE
    @previous_trade_timestamp = Time.now
    @previous_random_events =[]
    @has_pending_action=false
    @favorite_type = pick_favorite_type(trainerType)
  end

  def set_custom_appearance(trainer_appearance)
    @custom_appearance = trainer_appearance
  end

  def pick_favorite_type(trainer_type)
    if TRAINER_CLASS_FAVORITE_TYPES.has_key?(trainer_type)
      return TRAINER_CLASS_FAVORITE_TYPES[trainer_type].sample
    else
      return :NORMAL
    end
  end

  def set_pending_action(value)
    @has_pending_action=value
  end

  def log_evolution_event(unevolved_pokemon_species, evolved_pokemon_species)
    echoln "NPC Trainer #{@trainerName} evolved their #{get_species_readable_internal_name(unevolved_pokemon_species)} to #{get_species_readable_internal_name(evolved_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:EVOLVE)
    event.unevolved_pokemon = unevolved_pokemon_species
    event.evolved_pokemon = evolved_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_fusion_event(body_pokemon_species, head_pokemon_species, fused_pokemon_species)
    echoln "NPC trainer #{@trainerName} fused #{body_pokemon_species} and #{head_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:FUSE)
    event.fusion_body_pokemon =body_pokemon_species
    event.fusion_head_pokemon =head_pokemon_species
    event.fusion_fused_pokemon =fused_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_unfusion_event(original_fused_pokemon_species, unfused_body_species, unfused_body_head)
    echoln "NPC trainer #{@trainerName} unfused #{get_species_readable_internal_name(original_fused_pokemon_species)}!"
    event = BattledTrainerRandomEvent.new(:UNFUSE)
    event.unfused_pokemon = original_fused_pokemon_species
    event.fusion_body_pokemon = unfused_body_species
    event.fusion_head_pokemon = unfused_body_head
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_reverse_event(original_fused_pokemon_species, reversed_fusion_species)
    echoln "NPC trainer #{@trainerName} reversed #{get_species_readable_internal_name(original_fused_pokemon_species)}!"

    event = BattledTrainerRandomEvent.new(:REVERSE)
    event.unreversed_pokemon = original_fused_pokemon_species
    event.reversed_pokemon = reversed_fusion_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events << event
  end

  def log_catch_event(new_pokemon_species)
    echoln "NPC Trainer #{@trainerName} caught a #{new_pokemon_species}!"
    event = BattledTrainerRandomEvent.new(:CATCH)
    event.caught_pokemon = new_pokemon_species
    @previous_random_events = [] unless @previous_random_events
    @previous_random_events <<  event
  end

  def clear_previous_random_events()
    @previous_random_events = []
  end

  def loadOriginalTrainer(trainerVersion=0)
    return pbLoadTrainer(@trainerType,@trainerName,trainerVersion)
  end

  def loadOriginalTrainerTeam(trainerVersion=0)
    original_trainer = pbLoadTrainer(@trainerType,@trainerName,trainerVersion)
    return if !original_trainer
    echoln "Loading Trainer #{@trainerType}"
    current_party = []
    original_trainer.party.each do |partyMember|
      echoln "PartyMember: #{partyMember}"
      if partyMember.is_a?(Pokemon)
        current_party << partyMember
      elsif partyMember.is_a?(Array)  #normally always gonna be this
        pokemon_species = partyMember[0]
        pokemon_level = partyMember[1]
        current_party << Pokemon.new(pokemon_species,pokemon_level)
      else
        echoln "Could not add Pokemon #{partyMember} to rematchable trainer's party."
      end
    end

    return current_party
  end

  def getTimeSinceLastTrade()
    @previous_trade_timestamp ||= Time.now - DELAY_BETWEEN_NPC_TRADES
    return Time.now - @previous_trade_timestamp
  end

  def isNextTradeReady?()
    return getTimeSinceLastTrade < DELAY_BETWEEN_NPC_TRADES
  end

  def list_team_unfused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if !pokemon.isFusion?
    end
    return list
  end

  def list_team_fused_pokemon
    list = []
    @currentTeam.each do |pokemon|
      list << pokemon if pokemon.isFusion?
    end
    return list
  end
end