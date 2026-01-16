class PokemonTemp
  attr_accessor :fuse_count_today
  attr_accessor :unfuse_count_today
end

def checkFuseChallenges(head_species, body_species)
  case $PokemonTemp.fuse_count_today
  when 1
    $Trainer.complete_challenge(:fuse_1_pokemon)
  when 2
    $Trainer.complete_challenge(:fuse_2_pokemon)
  when 5
    $Trainer.complete_challenge(:fuse_5_pokemon)
  end

  if head_species == body_species
    $Trainer.complete_challenge(:fuse_same_species)
  end

  pokemon_head = GameData::Species.get(head_species)
  pokemon_body = GameData::Species.get(body_species)
  for type in pokemon_head&.types
    if pokemon_body.hasType?(type)
      $Trainer.complete_challenge(:fuse_same_type)
    end
  end
end

def checkUnfuseChallenges(unfused_pokemon)
  case $PokemonTemp.unfuse_count_today
  when 1
    $Trainer.complete_challenge(:unfuse_1_pokemon)
  when 2
    $Trainer.complete_challenge(:unfuse_2_pokemon)
  when 5
    $Trainer.complete_challenge(:unfuse_5_pokemon)
  end
end