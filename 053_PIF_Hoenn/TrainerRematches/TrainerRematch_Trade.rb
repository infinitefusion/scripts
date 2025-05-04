# frozen_string_literal: true

#prefered type depends on the trainer class
#
def generateTrainerTradeOffer(trainer)

  #todo
  #
  # NPC says "I'm looking for X or Y type Pokemon (prefered Pokemon can be determined when initializing from a pool of types that depends on the trainer class)
  # Also possible to pass a list of specific Pokemon in trainers.txt that the trainer will ask for instead if it's defined
  #
  # you select one of your Pokemon and he gives you one for it
  # prioritize recently caught pokemon
  # prioritive weaker Pokemon
  #
  #Assign a score to each Pokemon in trainer's team. calculate the same score for trainer's pokemon - select which
  # one is closer
  #
  # NPC says "I can offer A in exchange for your B.
  # -Yes -> Trade, update trainer team to put the player's pokemon in there
  #         Cannot trade again with the same trainer for 5 minutes
  #         "You just traded with this trainer. Wait a bit before you make another offer
  # -No
  trainer.set_pending_action(false) if trainer
  return trainer
end
