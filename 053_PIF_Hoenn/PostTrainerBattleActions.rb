

class PokemonGlobal
  #Map that keeps track of all the npc trainers the player has battled
  # [map_id,event_id] =>BattledTrainer
  attr_accessor :battledTrainers
end


class BattledTrainer
  attr_accessor :trainerType
  attr_accessor :trainerName

  attr_accessor :currentTeam  #list of Pokemon. The game selects in this list for trade offers. They can increase levels & involve as you rebattle them.
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


  def initialize(trainerType,trainerName)
    @trainerType = trainerType
    @trainerType = trainerName
    @currentTeam = nil #todo get from trainer data
    @foundItems = []
    @nb_rematches = 0
    @currentStatus = :IDLE
    @previous_status = :IDLE
    @previous_action_timestamp = Time.now
  end

  def getTimeSinceLastAction()
    return Time.now - @previous_action_timestamp
  end

end


## Extend pbTrainerBattle to call postTrainerBattleAction at the end of every trainer battle
alias original_pbTrainerBattle pbTrainerBattle
def pbTrainerBattle(trainerID, trainerName, *args)
  result = original_pbTrainerBattle(trainerID, trainerName, *args)
  postTrainerBattleActions(trainerID, trainerName)
  return result
end
def registerBattledTrainer(event_id, mapId, trainerType, trainerName)
  key = [event_id,mapId]
  $PokemonGlobal.battledTrainers = {} unless $PokemonGlobal.battledTrainers
  unless $PokemonGlobal.battledTrainers.has_key?(key)
    trainer = BattledTrainer.new(trainerType, trainerName)
    $PokemonGlobal.battledTrainers[key] = trainer
  end
end
def postTrainerBattleActions(trainerID, trainerName)
  registerBattledTrainer(@event_id,$game_map.map_id,trainerID,trainerName)
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

def makeRebattledTrainerTeamGainExp(eventId, mapId)
  trainer = getRebattledTrainer(eventId,mapId)
  updated_team = []
  for pokemon in trainer.currentTeam
    #todo:add exp (based on how strong the player's team is, maybe)
    # evolve if they need to
    updated_team.push(pokemon)
  end
  trainer.currentTeam = updated_team
  updateRebattledTrainer(eventId,mapId,trainer)
end



####
# Methods to be called from events
####

def generateTrainerRematch(event_id,map_id=nil)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event_id,map_id)
  return if !trainer

  #todo: do the battle lol
  # pbTrainerBattler(blabla)

  makeRebattledTrainerTeamGainExp(event_id,map_id)

end

#prefered type depends on the trainer class
#
def generateTrainerTradeOffer(event_id)

end


def generateTrainerGivenItem(event_id)

end


def getTrainerPostBattleAction(event_id,resultVariable=1)

end