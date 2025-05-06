




#####
# Util methods
#####








####
# Methods to be called from events
####












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
    trainer = doNPCTrainerRematch(trainer)
  when :TRADE
    trainer = doNPCTrainerTrade(trainer)
  end
  updateRebattledTrainer(event.id,map_id,trainer)

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

  options = []
  options << rematchCommand
  options << tradeCommand #todo: make it unlockable after a small tutorial by one of the early NPC trainers
  options << updateTeamDebugCommand if $DEBUG
  options << resetTrainerDebugCommand if $DEBUG
  options << printTrainerTeamDebugCommand if $DEBUG

  options << cancelCommand

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

