# todo : The idea is for each Elite 4 members to have a pool of 12 or so Pokémon (20 for Blue, but he always has his starter) to choose from and each time you rematch them, they pick 6 out
#   of them to give some variety and unpredictabilty o the fights

#  todo maybe: Analyse the player's team and pick a team that counters it

# Rematch tiers:
# :1 : Unlocked after beating the league the first time (Level range same as first run (50-60) )
# :2 : Unlocked after beating Elite 4 rematch tier 1 (Level range 60-70)
# :3 : Unlocked after beating Mt. Silver  and beating Elite 4 rematch tier 2 (Level range 70-80 )
#  4: Unlocked after completing all the Gym Leader rematches and beating Elite 4 rematch tier 3 (Level range 80-90)
#  5: Unlocked after beating rematch tier 4 (Everything level 100)
def eliteFourRematch(trainer_id, trainer_name, rematch_tier,end_dialog="")
  base_line_level = 50
  base_line_level = 60 if rematch_tier == 2
  base_line_level = 70 if rematch_tier == 3
  base_line_level = 80 if rematch_tier == 4
  base_line_level = 100 if rematch_tier == 5

  available_pokemon = E4_POKEMON_POOL[trainer_id]
  nb_pokemon = rematch_tier >= 3 ? 6 : 5
  nb_pokemon = 5 if trainer_id == :CHAMPION # Rival always has his starter

  selected_pokemon = select_e4_pokemon(available_pokemon, nb_pokemon)
  selected_pokemon << RIVAL_STARTER_E4_TEMPLATE if trainer_id == :CHAMPION
  party = build_e4_trainer_party(selected_pokemon, base_line_level)

  return customTrainerBattle(trainer_name,trainer_id,party,50,end_dialog)
end


def build_e4_trainer_party(selected_pokemon,base_line_level)
  party = []
  selected_pokemon.each do |pokemon_data|
    level = pokemon_data[:level] + base_line_level
    level = 100 if level > 100
    species_data = pokemon_data[:species]
    if species_data.is_a?(Array)
      species = fusionOf(species_data[0],species_data[1])
    else
      species = species_data
    pokemon = Pokemon.new(species, level)
    pokemon.ability = pokemon_data[:ability] if pokemon_data[:ability]
    pokemon.item = pokemon_data[:item] if pokemon_data[:item]
    moves = []
    pokemon_data[:moves].each do |move_id|
      moves << Pokemon::Move.new(move_id)
    end
    pokemon.moves = moves
    party << pokemon
  end
  return party
end
end

# Todo: smart select depending on the player's team
def select_e4_pokemon(all_available_pokemon,tier, number_to_select)
  available_pokemon = all_available_pokemon.select { |data| data[:tier] >= tier }
  return available_pokemon.sample(number_to_select)
end


def list_unlocked_league_tiers
  unlocked_tiers =[]
  unlocked_tiers << 1 if $game_switches[SWITCH_BEAT_THE_LEAGUE]
  unlocked_tiers << 2 if $game_switches[SWITCH_LEAGUE_TIER_2]
  unlocked_tiers << 3 if $game_switches[SWITCH_LEAGUE_TIER_3] && $game_switches[SWITCH_BEAT_THE_LEAGUE] #todo: and beat second rematch
  unlocked_tiers << 4 if $game_variables[SWITCH_LEAGUE_TIER_4] >= 12 && $game_switches[SWITCH_BEAT_THE_LEAGUE] #todo: and beat third rematch
  unlocked_tiers << 5 if $game_switches[SWITCH_LEAGUE_TIER_5] #todo: and beat fourth rematch
  return available_tiers
end
def select_league_tier
  available_tiers =list_unlocked_league_tiers
  return 0 if available_tiers.empty?
  return available_tiers[0] if available_tiers.length == 1

  commands = []
  available_tiers.each do |tier_nb|
    commands << _INTL("Tier #{tier_nb}")
  end

  choice = pbMessage("Which League Rematch difficulty tier will you choose?",commands)
  return available_tiers[choice]
end

#called when the player just beat the league
def unlock_new_league_tiers
  current_tier = pbGet(VAR_LEAGUE_REMATCH_TIER)
  currently_unlocked_tiers = list_unlocked_league_tiers

  tiers_to_unlock = []
  tiers_to_unlock << 1 if current_tier == 0
  tiers_to_unlock << 2 if current_tier == 1
  tiers_to_unlock << 3 if current_tier == 2 && $game_switches[SWITCH_BEAT_MT_SILVER]
  tiers_to_unlock << 4 if current_tier == 3 && $game_variables[VAR_NB_GYM_REMATCHES] >= 16
  tiers_to_unlock << 5 if current_tier == 4


  tiers_to_unlock.each do |tier|
    unless currently_unlocked_tiers.include?(tier)
      pbMEPlay("Key item get")
      pbMessage(_INTL("#{$Trainer.name} unlocked the \\C[1]Tier #{tier} League Rematches\\C[0]!"))
    end
  end
end