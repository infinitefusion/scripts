# frozen_string_literal: true
HOENN_RIVAL_EVENT_NAME = "HOENN_RIVAL"
TEMPLATE_CHARACTER_FILE = "NPC_template"

HOENN_RIVAL_APPEARANCE_M = TrainerAppearance.new(5,
                                                 HAT_BRENDAN,
                                                 CLOTHES_BRENDAN,
                                                 getFullHairId(HAIR_BRENDAN,3),
                                                 0, 0, 0)

HOENN_RIVAL_APPEARANCE_F = TrainerAppearance.new(5,
                                                 HAT_MAY,
                                                 CLOTHES_MAY,
                                                 getFullHairId(HAIR_MAY,3) ,
                                                 0, 0, 0)

BATTLED_TRAINER_RIVAL_KEY = "rival"


class Sprite_Character
  alias PIF_typeExpert_checkModifySpriteGraphics checkModifySpriteGraphics
  def checkModifySpriteGraphics(character)
    PIF_typeExpert_checkModifySpriteGraphics(character)
    return if character == $game_player
    echoln character.character_name
    echoln TEMPLATE_CHARACTER_FILE
    echoln character.character_name == TEMPLATE_CHARACTER_FILE
    setSpriteToAppearance(HOENN_RIVAL_APPEARANCE_M) if isPlayerFemale && character.name == HOENN_RIVAL_EVENT_NAME && character.character_name == TEMPLATE_CHARACTER_FILE
    setSpriteToAppearance(HOENN_RIVAL_APPEARANCE_F) if isPlayerMale && character.name == HOENN_RIVAL_EVENT_NAME && character.character_name == TEMPLATE_CHARACTER_FILE
  end
end

def get_rival_starter
  case get_rival_starter_type()
  when :GRASS
    return obtainStarter(0)
  when :FIRE
    return obtainStarter(1)
  when :WATER
    return obtainStarter(2)
  else
          #fallback, should not happen
          return obtainStarter(0)
  end
end


def get_rival_starter_type()
  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 #GRASS
    return :FIRE
  when 1 #FIRE
    return :WATER
  when 2 #WATER
    return :GRASS
  end
end



# This sets up the rival's main team for the game
# Fir further battle, we can just add Pokemon and gain exp the same way as other
# trainer rematches
#
# Basically, rival catches a pokemon the type of their rival's starter - fuses it with their starters
# Has a team composed of fire/grass, water/grass, water/fire pokemon
def updateRivalTeamForSecondBattle()
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_starter = rival_trainer.currentTeam[0]
  starter_species= rival_starter.species

  rival_starter.level=20
  evolution_species = rival_starter.check_evolution_on_level_up(false)
  if evolution_species
    starter_species = evolution_species
  end

  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 #GRASS
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE, starter_species)
      water_fire_pokemon = getFusionSpeciesSymbol(:NUMEL,:WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER,:SHROOMISH)
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(starter_species,:SHROOMISH)
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE,:WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:WAILMER)
    end
    contains_starter = [fire_grass_pokemon]
    other_pokemon = [water_fire_pokemon,water_grass_pokemon]

  when 1 #FIRE
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SHROOMISH,:NUMEL)
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE,:WAILMER)
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,starter_species)
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE,:SLUGMA,)
      water_fire_pokemon = getFusionSpeciesSymbol(:SHROOMISH,:WINGULL,)
      water_grass_pokemon = getFusionSpeciesSymbol(starter_species,:NUMEL)
    end
    contains_starter = [water_grass_pokemon]
    other_pokemon = [water_fire_pokemon,fire_grass_pokemon]

  when 2 #WATER
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:SHROOMISH)
      water_fire_pokemon = getFusionSpeciesSymbol(starter_species,:WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER,:NUMEL)
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE,:NUMEL,)
      water_fire_pokemon = getFusionSpeciesSymbol(:GROVYLE,starter_species)
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA,:WINGULL)
    end
    contains_starter = [water_fire_pokemon]
    other_pokemon = [water_grass_pokemon,fire_grass_pokemon]
  end

  team = []
  team << Pokemon.new(other_pokemon[0],18)
  team << Pokemon.new(other_pokemon[1],18)
  team << Pokemon.new(contains_starter[0],20)

  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end


def initializeRivalBattledTrainer
  trainer_type = :RIVAL1
  trainer_name = isPlayerMale ? "May" : "Brendan"
  trainer_appearance = isPlayerMale ? HOENN_RIVAL_APPEARANCE_F : HOENN_RIVAL_APPEARANCE_M
  rivalBattledTrainer = BattledTrainer.new(trainer_type,trainer_name,0)
  rivalBattledTrainer.set_custom_appearance(trainer_appearance)
  echoln rivalBattledTrainer.currentTeam
  team = []
  team<<Pokemon.new(get_rival_starter,5)
  rivalBattledTrainer.currentTeam =team
  return rivalBattledTrainer
end

def hoennRivalBattle(loseDialog="...")
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  if !$PokemonGlobal.battledTrainers.has_key?(BATTLED_TRAINER_RIVAL_KEY)
    rival_trainer = initializeRivalBattledTrainer()
    $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  else
    rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  end
  echoln rival_trainer
  echoln rival_trainer.currentTeam

  return customTrainerBattle(rival_trainer.trainerName,rival_trainer.trainerType, rival_trainer.currentTeam,rival_trainer,loseDialog,nil,rival_trainer.custom_appearance)
end