




#####
# Util methods
#####








####
# Methods to be called from events
####


#actionType :
# :BATTLE
# :TRADE
# :PARTNER
def doPostBattleAction(actionType,double_allowed=true)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer.clear_previous_random_events()

  return if !trainer
  case actionType
  when :BATTLE
    trainer,player_won = generateTrainerRematch(trainer,double_allowed)
  when :TRADE
    trainer = doNPCTrainerTrade(trainer)
  when :PARTNER
    partnerWithTrainer(event.id,map_id,trainer)
  end
  updateRebattledTrainer(event.id,map_id,trainer)

end

def setTrainerFriendship(trainer)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue($game_map.map_id)
  number = pbMessageChooseNumber(_INTL("Frienship (0-100)?"),params)
  trainer.friendship = number
  trainer.increase_friendship(0)
  return trainer
end

#party: array of pokemon team
# [[:SPECIES,level], ... ]
#
#def customTrainerBattle(trainerName, trainerType, party_array, default_level=50, endSpeech="", sprite_override=nil,custom_appearance=nil)
def postBattleActionsMenu()
  rematchCommand = _INTL("Rematch")

  rematchSingleCommand = _INTL("Rematch (Single)")
  rematchDoubleCommand = _INTL("Rematch (Double)")

  tradeCommand = _INTL("Trade Offer")
  partnerCommand = _INTL("Partner up")
  cancelCommand = _INTL("See ya!")

  updateTeamDebugCommand = _INTL("(Debug) Simulate random event")
  resetTrainerDebugCommand = _INTL("(Debug) Reset trainer")
  setFriendshipDebugCommand = _INTL("(Debug) Set Friendship")
  printTrainerTeamDebugCommand = _INTL("(Debug) Print team")


  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  return unless trainer
  options = []
  if trainer.getLinkedTrainer
    options << rematchSingleCommand if trainer.friendship_level >=1
    options << rematchDoubleCommand
  else
    options << rematchCommand
  end
  options << tradeCommand if trainer.friendship_level >= 1
  #options << partnerCommand if trainer.friendship_level >= 3

  options << updateTeamDebugCommand if $DEBUG
  options << resetTrainerDebugCommand if $DEBUG
  options << setFriendshipDebugCommand if $DEBUG
  options << printTrainerTeamDebugCommand if $DEBUG

  options << cancelCommand

  trainer = applyTrainerRandomEvents(trainer)
  if trainer.has_pending_action
    try_give_gift(trainer)  #only when there's a pending action so that it can't be abused by talking to the npc over and over
  end
  showPrerematchDialog
  choice = optionsMenu(options,options.find_index(cancelCommand),options.find_index(cancelCommand))
  case options[choice]
  when rematchCommand
    doPostBattleAction(:BATTLE)
  when rematchSingleCommand
    doPostBattleAction(:BATTLE,false)
  when rematchDoubleCommand
    doPostBattleAction(:BATTLE,true)
  when tradeCommand
    doPostBattleAction(:TRADE)
  when partnerCommand
    doPostBattleAction(:PARTNER)
  when updateTeamDebugCommand
    echoln("")
    echoln "---------------"
    makeRebattledTrainerTeamGainExp(trainer,true)
    evolveRebattledTrainerPokemon(trainer)
    applyTrainerRandomEvents(trainer)
  when resetTrainerDebugCommand
    resetTrainerRebattle(event.id,map_id)
  when setFriendshipDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    trainer = setTrainerFriendship(trainer)
    updateRebattledTrainer(event.id,map_id,trainer)
  when printTrainerTeamDebugCommand
    trainer = getRebattledTrainer(event.id,map_id)
    printNPCTrainerCurrentTeam(trainer)
  when cancelCommand
  else
    return
  end
end

def try_give_gift(trainer)
  if should_give_item(trainer)
    item = select_gift_item(trainer)
    showGiftDialog()
    pbReceiveItem(item)
    return true
  end
  return false
end

#leave event_type empty for random
def forceRandomRematchEventOnTrainer(event_type=nil)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  while !trainer.has_pending_action
    trainer = applyTrainerRandomEvents(trainer,event_type)
  end
  updateRebattledTrainer(event.id,map_id,trainer)
end

def forceTrainerFriendshipOnTrainer(friendship=0)
  event = pbMapInterpreter.get_character(0)
  map_id = $game_map.map_id if map_id.nil?
  trainer = getRebattledTrainer(event.id,map_id)
  trainer.friendship = friendship
  trainer.increase_friendship(0)
  updateRebattledTrainer(event.id,map_id,trainer)
end
