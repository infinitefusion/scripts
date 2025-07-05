
BATTLED_TRAINER_WALLY_KEY = "wally"

SWITCH_WALLY_CATCHING_POKEMON = 2022
SWITCH_WALLY_GAVE_POKEMON_DIALOGUE = 2024

COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE = 199

def wally_initialize(starter_species)
  trainer_type = :RIVAL2
  trainer_name = "Wally"
  battledTrainer = BattledTrainer.new(trainer_type,trainer_name,0)
  echoln battledTrainer.currentTeam
  team = []
  starter = Pokemon.new(starter_species,5)
  starter.moves=[]
  starter.pbLearnMove(:GROWL)
  starter.pbLearnMove(:TAILWHIP)
  team << starter
  battledTrainer.currentTeam =team
  $PokemonGlobal.battledTrainers={} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY] = battledTrainer
  return battledTrainer
end

def wally_follow(eventId)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  partnerWithTrainer(eventId, $game_map.map_id, trainer,BATTLED_TRAINER_WALLY_KEY, COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE)
end

def wally_unfollow()
  unpartnerWithTrainer()
end
