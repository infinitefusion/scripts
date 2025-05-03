

class PokemonGlobalMetadata
  #Map that keeps track of all the npc trainers the player has battled
  # [map_id,event_id] =>BattledTrainer
  attr_accessor :battledTrainers
end

TIME_FOR_RANDOM_EVENTS = 60#3600 #1 hour


## Extend pbTrainerBattle to call postTrainerBattleAction at the end of every trainer battle
alias original_pbTrainerBattle pbTrainerBattle
def pbTrainerBattle(trainerID, trainerName,endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0,
                    *args)
  result = original_pbTrainerBattle(trainerID, trainerName, *args)
  postTrainerBattleActions(trainerID, trainerName,trainerPartyID) #if Settings::GAME_ID == :IF_HOENN
  return result
end
def postTrainerBattleActions(trainerID, trainerName,trainerVersion)
  trainer = registerBattledTrainer(@event_id,$game_map.map_id,trainerID,trainerName,trainerVersion)
  makeRebattledTrainerTeamGainExp(trainer)
end


#Do NOT call this alone. Rebattlable trainers are always intialized after
# defeating them.
# Having a rematchable trainer that is not registered will cause crashes.
def registerBattledTrainer(event_id, mapId, trainerType, trainerName, trainerVersion=0)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  trainer = BattledTrainer.new(trainerType, trainerName, trainerVersion)
  $PokemonGlobal.battledTrainers[key] = trainer
  return trainer
end

def unregisterBattledTrainer(event_id, mapId)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  if  $PokemonGlobal.battledTrainers.has_key?(key)
    $PokemonGlobal.battledTrainers[key] =nil
    echoln "Unregistered Battled Trainer #{key}"
  else
    echoln "Could not unregister Battled Trainer #{key}"
  end
end

def resetTrainerRebattle(event_id, map_id)
  trainer = getRebattledTrainer(event_id,map_id)

  trainerType = trainer.trainerType
  trainerName = trainer.trainerName

  unregisterBattledTrainer(event_id,map_id)
  registerBattledTrainer(event_id,map_id,trainerType,trainerName)
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
  return if !trainer
  updated_team = []

  trainer_pokemon = $Trainer.party[0]

  for pokemon in trainer.currentTeam
    gained_exp = trainer_pokemon.level * trainer_pokemon.base_exp
    gained_exp /= 2 if playerWon   #trainer lost so he's not getting full exp
    gained_exp /= trainer.currentTeam.length

    growth_rate = pokemon.growth_rate
    new_exp = growth_rate.add_exp(pokemon.exp, gained_exp)
    pokemon.exp = new_exp
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  return trainer
end

def evolveRebattledTrainerPokemon(trainer)
  updated_team = []
  for pokemon in trainer.currentTeam
    evolution_species = pokemon.check_evolution_on_level_up(false)
    if evolution_species
      trainer.log_evolution_event(pokemon.species,evolution_species)
      trainer.set_pending_action(true)
      pokemon.species = evolution_species if evolution_species
    end
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
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
  trainer.set_pending_action(false) if trainer
  return trainer
end


####
# Methods to be called from events
####

def generateTrainerRematch(trainer)
  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)

  loseDialog = trainer_data&.loseText_rematch ? trainer_data.loseText_rematch :  "..."
  if customTrainerBattle(trainer.trainerName,trainer.trainerType, trainer.currentTeam,nil,loseDialog)
    updated_trainer = makeRebattledTrainerTeamGainExp(trainer,true)
    updated_trainer = healRebattledTrainerPokemon(updated_trainer)
  else
    updated_trainer =makeRebattledTrainerTeamGainExp(trainer,false)
  end
  updated_trainer.set_pending_action(false)
  updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
  return updated_trainer

end


def printNPCTrainerCurrentTeam(trainer)
  team_string = "["
  trainer.currentTeam.each do |pokemon|
    name= get_pokemon_readable_internal_name(pokemon)
    level = pokemon.level
    formatted_info = "#{name} (lv.#{level}), "
    team_string += formatted_info
  end
  team_string += "]"
  echoln "Trainer's current team is: #{team_string}"

end

def applyTrainerRandomEvents(trainer)
  return if trainer.has_pending_action
  trainer.clear_previous_random_events

  time_passed = trainer.getTimeSinceLastAction
  return trainer if time_passed < TIME_FOR_RANDOM_EVENTS

  # Weighted chances out of 10
  weighted_events = [
    [:CATCH,   3],
    [:FUSE,    6],
    [:REVERSE, 1],
    [:UNFUSE,  2]
  ]

  # Create a flat array of events based on weight
  event_pool = weighted_events.flat_map { |event, weight| [event] * weight }

  selected_event = event_pool.sample
  return trainer if selected_event.nil?

  case selected_event
  when :CATCH
    trainer = catch_new_team_pokemon(trainer)
  when :FUSE
    trainer = fuse_random_team_pokemon(trainer)
  when :UNFUSE
    trainer = unfuse_random_team_pokemon(trainer)
  when :REVERSE
    trainer = reverse_random_team_pokemon(trainer)
  end
  trainer.set_pending_action(true)
  printNPCTrainerCurrentTeam(trainer)
  return trainer
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
  #echoln "possible_encounter_types: #{possible_encounter_types}"
  return possible_encounter_types.sample
end

def catch_new_team_pokemon(trainer)
  return trainer if trainer.currentTeam.length >= 6
  encounter_type = chooseEncounterType(trainer.trainerType)
  return trainer if !encounter_type
  wild_pokemon = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  trainer.currentTeam << Pokemon.new(wild_pokemon[0],wild_pokemon[1])
  trainer.log_catch_event(wild_pokemon[0])
  return trainer
end




def reverse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_fused_pokemon
  return trainer if eligible_pokemon.length < 1
  return trainer if trainer.currentTeam.length > 5
  pokemon_to_reverse = eligible_pokemon.sample
  old_species = pokemon_to_reverse.species
  trainer.currentTeam.delete(pokemon_to_reverse)

  body_pokemon = get_body_species_from_symbol(pokemon_to_reverse.species)
  head_pokemon = get_head_species_from_symbol(pokemon_to_reverse.species)

  pokemon_to_reverse.species = getFusedPokemonIdFromSymbols(head_pokemon,body_pokemon)
  trainer.currentTeam.push(pokemon_to_reverse)
  trainer.log_reverse_event(old_species,pokemon_to_reverse.species)
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
  trainer.log_unfusion_event(pokemon_to_unfuse.species, body_pokemon, head_pokemon)
  return trainer
end

def fuse_random_team_pokemon(trainer)
  eligible_pokemon = trainer.list_team_unfused_pokemon
  return trainer if eligible_pokemon.length < 2

  pokemon_to_fuse = eligible_pokemon.sample(2)
  body_pokemon = pokemon_to_fuse[0]
  head_pokemon = pokemon_to_fuse[1]
  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species,head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level)/2
  fused_pokemon = Pokemon.new(fusion_species,level)

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)
  trainer.log_fusion_event(body_pokemon.species,head_pokemon.species,fusion_species)
  return trainer
end





#actionType :
# :BATTLE
# :TRADE
def doPostBattleAction(actionType)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer.clear_previous_random_events()

  return if !trainer
  case actionType
  when :BATTLE
    trainer = generateTrainerRematch(trainer)
  when :TRADE
    trainer = generateTrainerTradeOffer(trainer)
  end
  updateRebattledTrainer(event.id,map_id,trainer)

end



def getBestMatchingPreviousRandomEvent(trainer_data, previous_events)
  return nil if trainer_data.nil? || previous_events.nil?

  priority = [:CATCH, :EVOLVE, :FUSE, :UNFUSE, :REVERSE]
  event_message_map = {
    CATCH:   trainer_data.preRematchText_caught,
    EVOLVE:  trainer_data.preRematchText_evolved,
    FUSE:    trainer_data.preRematchText_fused,
    UNFUSE:  trainer_data.preRematchText_unfused,
    REVERSE: trainer_data.preRematchText_reversed
  }
  sorted_events = previous_events.sort_by do |event|
    priority.index(event.eventType) || Float::INFINITY
  end

  sorted_events.find { |event| event_message_map[event.eventType] }
end


def showPrerematchDialog()
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  return "" if trainer.nil?

  trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)

  all_previous_random_events = trainer.previous_random_events


  if all_previous_random_events
    previous_random_event = getBestMatchingPreviousRandomEvent(trainer_data, trainer.previous_random_events)

    if previous_random_event
      event_message_map = {
        CATCH:   trainer_data.preRematchText_caught,
        EVOLVE:  trainer_data.preRematchText_evolved,
        FUSE:    trainer_data.preRematchText_fused,
        UNFUSE:  trainer_data.preRematchText_unfused,
        REVERSE: trainer_data.preRematchText_reversed
      }

      message_text = event_message_map[previous_random_event.eventType] || trainer_data.preRematchText
    else
      message_text = trainer_data.preRematchText
    end
  end

  if previous_random_event
    message_text = message_text.gsub("<CAUGHT_POKEMON>", getSpeciesRealName(previous_random_event.caught_pokemon).to_s)
    message_text = message_text.gsub("<UNEVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.unevolved_pokemon).to_s)
    message_text = message_text.gsub("<EVOLVED_POKEMON>", getSpeciesRealName(previous_random_event.evolved_pokemon).to_s)
    message_text = message_text.gsub("<HEAD_POKEMON>", getSpeciesRealName(previous_random_event.fusion_head_pokemon).to_s)
    message_text = message_text.gsub("<BODY_POKEMON>", getSpeciesRealName(previous_random_event.fusion_body_pokemon).to_s)
    message_text = message_text.gsub("<FUSED_POKEMON>", getSpeciesRealName(previous_random_event.fusion_fused_pokemon).to_s)
    message_text = message_text.gsub("<UNREVERSED_POKEMON>", getSpeciesRealName(previous_random_event.unreversed_pokemon).to_s)
    message_text = message_text.gsub("<REVERSED_POKEMON>", getSpeciesRealName(previous_random_event.reversed_pokemon).to_s)
    message_text = message_text.gsub("<UNFUSED_POKEMON>", getSpeciesRealName(previous_random_event.unfused_pokemon).to_s)
  else
    message_text = trainer_data.preRematchText
  end
  if message_text
    split_messages = message_text.split("<br>")
    split_messages.each do |msg|
      pbCallBub(2,event.id)
      pbMessage(msg)
    end
  end

end


#party: array of pokemon team
# [[:SPECIES,level], ... ]
#
#def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil,custom_appearance=nil)
def postBattleActionsMenu()
  rematchCommand = "Rematch"
  tradeCommand = "Trade Offer"
  cancelCommand = "See ya!"

  updateTeamDebugCommand = "(Debug) Simulate random event"
  resetTrainerDebugCommand = "(Debug) Reset trainer"
  printTrainerTeamDebugCommand = "(Debug) Print team"

  options = [rematchCommand,tradeCommand,cancelCommand]
  options << updateTeamDebugCommand if $DEBUG
  options << resetTrainerDebugCommand if $DEBUG
  options << printTrainerTeamDebugCommand if $DEBUG

  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer = applyTrainerRandomEvents(trainer)
  showPrerematchDialog
  choice = optionsMenu(options,options.find_index(cancelCommand),options.find_index(cancelCommand))

  case options[choice]
  when rematchCommand
    doPostBattleAction(:BATTLE)
  when tradeCommand
    doPostBattleAction(:TRADE)
  when updateTeamDebugCommand
    echoln("")
    echoln "---------------"
    makeRebattledTrainerTeamGainExp(trainer,true)
    evolveRebattledTrainerPokemon(trainer)
    applyTrainerRandomEvents(trainer)
  when resetTrainerDebugCommand
    resetTrainerRebattle(event.id,map_id)
  when printTrainerTeamDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    printNPCTrainerCurrentTeam(trainer)
  when cancelCommand
  else
    return
  end


end


def generateTrainerGivenItem()
  event = pbMapInterpreter.get_character(0)
end


def getTrainerPostBattleAction(resultVariable=1)
  event = pbMapInterpreter.get_character(0)

end