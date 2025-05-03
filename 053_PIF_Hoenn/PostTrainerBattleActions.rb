

class PokemonGlobalMetadata
  #Map that keeps track of all the npc trainers the player has battled
  # [map_id,event_id] =>BattledTrainer
  attr_accessor :battledTrainers
end

TIME_FOR_RANDOM_EVENTS = 60#3600 #1 hour

class BattledTrainer
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
  attr_accessor :previous_action_timestamp

  attr_accessor :favorite_pokemon #Used for generating trade offers. Should be set from trainer.txt (todo)
  #If empty, then trade offers ask for a Pokemon of a type depending on the trainer's class

  def initialize(trainerType,trainerName,trainerVersion)
    @trainerType = trainerType
    @trainerName = trainerName
    @currentTeam = loadOriginalTrainerTeam(trainerVersion)
    @foundItems = []
    @nb_rematches = 0
    @currentStatus = :IDLE
    @previous_status = :IDLE
    @previous_action_timestamp = Time.now
  end

  def loadOriginalTrainerTeam(trainerVersion=0)
    original_trainer = pbLoadTrainer(@trainerType,@trainerName,trainerVersion)
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

  def getTimeSinceLastAction()
    return Time.now - @previous_action_timestamp
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


## Extend pbTrainerBattle to call postTrainerBattleAction at the end of every trainer battle
alias original_pbTrainerBattle pbTrainerBattle
def pbTrainerBattle(trainerID, trainerName,endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0,
                    *args)
  result = original_pbTrainerBattle(trainerID, trainerName, *args)
  postTrainerBattleActions(trainerID, trainerName,trainerPartyID) if Settings::GAME_ID == :IF_HOENN
  return result
end
def registerBattledTrainer(event_id, mapId, trainerType, trainerName, trainerVersion)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  trainer = BattledTrainer.new(trainerType, trainerName, trainerVersion)
  $PokemonGlobal.battledTrainers[key] = trainer
end
def postTrainerBattleActions(trainerID, trainerName,trainerVersion)
  registerBattledTrainer(@event_id,$game_map.map_id,trainerID,trainerName,trainerVersion)
  makeRebattledTrainerTeamGainExp(@event_id,$game_map.map_id)
end


#####
# Util methods
#####

def updateRebattledTrainer(event_id,map_id,updated_trainer)
  key = [event_id,map_id]
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[key] = updated_trainer
end

def getRebattledTrainer(event_id,map_id)
  key = [event_id,map_id]
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  return $PokemonGlobal.battledTrainers[key]
end


# After each rematch, all of the trainer's Pokémon gain EXP
#
# Gained Exp is calculated from the Pokemon that is in the first slot in the player's team
# so the trainer's levels will scale with the player's.
#
# e.g. If the player uses a stronger Pokemon in the battle, the NPC will get more experience
# as a result
#
def makeRebattledTrainerTeamGainExp(trainer, playerWon=true)
  updated_team = []

  trainer_pokemon = $Trainer.party[0]

  for pokemon in trainer.currentTeam
    gained_exp = trainer_pokemon.level * trainer_pokemon.base_exp
    gained_exp /= 2 if playerWon   #trainer lost so he's not getting full exp
    gained_exp /= trainer.currentTeam.length

    growth_rate = pokemon.growth_rate
    new_exp = growth_rate.add_exp(pokemon.exp, gained_exp)
    pokemon.exp = new_exp
    echoln new_exp
    #todo:add exp (based on how strong the player's team is, maybe)
    # evolve if they need to
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  echoln trainer.currentTeam
  return trainer
end

def evolveRebattledTrainerPokemon(trainer)
  updated_team = []
  for pokemon in trainer.currentTeam
    evolution_species = pokemon.check_evolution_on_level_up
    if evolution_species
      echoln "NPC Trainer #{trainer.trainerName} evolved their #{pokemon.species} to #{evolution_species}!"
      pokemon.species = evolution_species if evolution_species
    end
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  echoln trainer.currentTeam
  return trainer
end

def healRebattledTrainerPokemon(trainer)
  for pokemon in trainer.currentTeam
    pokemon.calc_stats
    pokemon.heal
  end
  return trainer
end


#prefered type depends on the trainer class
#
def generateTrainerTradeOffer(trainer)
  return trainer
end




####
# Methods to be called from events
####

def generateTrainerRematch(trainer)
  end_speech = "You won again!"
  #todo - Add rebattle speech to trainer metadata?
  # - Or just pass it to the method from the event.
  if customTrainerBattle(trainer.trainerName,trainer.trainerType, trainer.currentTeam,nil,end_speech)
    updated_trainer = makeRebattledTrainerTeamGainExp(trainer,true)
    updated_trainer = healRebattledTrainerPokemon(updated_trainer)
  else
    updated_trainer =makeRebattledTrainerTeamGainExp(trainer,false)
  end
  updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
  return updated_trainer

end




def applyTrainerRandomEvents(trainer)
  time_passed = trainer.getTimeSinceLastAction
  return trainer if time_passed < TIME_FOR_RANDOM_EVENTS

  #Chances of each event happening (out of 10)
  chance_of_new_pokemon = 3
  chance_of_fuse    = 6
  chance_of_reverse = 1
  chance_of_unfuse = 2

  should_add_pokemon = rand(10) < chance_of_new_pokemon
  should_unfuse = rand(10) < chance_of_unfuse
  should_fuse = rand(10) < chance_of_fuse
  should_reverse = rand(10) < chance_of_reverse

  updated_trainer = trainer
  updated_trainer = catch_new_team_pokemon(updated_trainer) if should_add_pokemon
  updated_trainer = unfuse_random_team_pokemon(updated_trainer) if should_unfuse
  updated_trainer = fuse_random_team_pokemon(updated_trainer) if should_fuse
  updated_trainer = reverse_random_team_pokemon(updated_trainer) if should_reverse
  return updated_trainer
end

def chooseEncounterType(trainerClass)
  water_trainer_classes = [:SWIMMER_F, :SWIMMER_M, :FISHERMAN]
  if water_trainer_classes.include?(trainerClass )
    chance_of_land_encounter = 1
    chance_of_surf_encounter= 5
    chance_of_cave_encounter = 1
    chance_of_fishing_encounter = 5
  else
    chance_of_land_encounter = 5
    chance_of_surf_encounter= 1
    chance_of_cave_encounter = 5
    chance_of_fishing_encounter = 1
  end

  if pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, false)
    chance_of_surf_encounter =0
    chance_of_fishing_encounter = 0
  end

  possible_encounter_types = []
  if $PokemonEncounters.has_land_encounters?
    possible_encounter_types += [:Land] * chance_of_land_encounter
  end
  if $PokemonEncounters.has_cave_encounters?
    possible_encounter_types += [:Cave] * chance_of_cave_encounter
  end
  if $PokemonEncounters.has_water_encounters?
    possible_encounter_types += [:GoodRod] * chance_of_fishing_encounter
    possible_encounter_types += [:Water] * chance_of_surf_encounter
  end
  echoln "possible_encounter_types: #{possible_encounter_types}"
  return possible_encounter_types.sample
end

def catch_new_team_pokemon(trainer)
  return trainer if trainer.currentTeam.length >= 6
  encounter_type = chooseEncounterType(trainer.trainerType)
  return trainer if !encounter_type
  wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  trainer.currentTeam << Pokemon.new(wild_pokemon[0],wild_pokemon[1])
  echoln "NPC Trainer #{trainer.trainerName} caught a #{wild_pokemon} since last time!"
  return trainer
end




def reverse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_reverse = eligible_pokemon.sample
  trainer.currentTeam.delete(pokemon_to_reverse)

  body_pokemon = get_body_species_from_symbol(pokemon_to_reverse.species)
  head_pokemon = get_head_species_from_symbol(pokemon_to_reverse.species)

  pokemon_to_reverse.species = getFusedPokemonIdFromSymbols(head_pokemon,body_pokemon)
  trainer.currentTeam.push(pokemon_to_reverse)

  echoln "NPC trainer reversed #{pokemon_to_reverse} into #{pokemon_to_reverse.species}!"
  return trainer
end


def unfuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_unfuse = eligible_pokemon.sample
  body_pokemon = get_body_id_from_symbol(pokemon_to_unfuse.species)
  head_pokemon = get_head_id_from_symbol(pokemon_to_unfuse.species)

  level = calculateUnfuseLevelOldMethod(pokemon_to_unfuse,false)

  trainer.currentTeam.delete(pokemon_to_unfuse)
  trainer.currentTeam.push(Pokemon.new(body_pokemon,level))
  trainer.currentTeam.push(Pokemon.new(head_pokemon,level))
  echoln "NPC trainer unfused #{pokemon_to_unfuse}!"
  return trainer
end

def fuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_unfused_pokemon
  return trainer if eligible_pokemon.length < 2

  pokemon_to_fuse = eligible_pokemon.sample(2)
  body_pokemon = pokemon_to_fuse[0]
  head_pokemon = pokemon_to_fuse[1]

  echoln body_pokemon
  echoln head_pokemon

  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species,head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level)/2
  fused_pokemon = Pokemon.new(fusion_species,level)

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)
  echoln "NPC trainer fused #{body_pokemon.species} and #{head_pokemon.species}!"
  return trainer
end



#actionType :
# :BATTLE
# :TRADE
def doPostBattleAction(actionType)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  return if !trainer
  updated_trainer = applyTrainerRandomEvents(trainer)
  case actionType
  when :BATTLE
    updated_trainer = generateTrainerRematch(updated_trainer)
  when :TRADE
    updated_trainer = generateTrainerTradeOffer(updated_trainer)
  end
  updateRebattledTrainer(event.id,map_id,updated_trainer)
end

#party: array of pokemon team
# [[:SPECIES,level], ... ]
#
#def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil,custom_appearance=nil)




def generateTrainerGivenItem()
  event = pbMapInterpreter.get_character(0)

end


def getTrainerPostBattleAction(resultVariable=1)
  event = pbMapInterpreter.get_character(0)

end