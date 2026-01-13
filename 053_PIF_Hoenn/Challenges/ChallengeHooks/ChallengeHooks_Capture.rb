module PokeBattle_BattleCommon
  def checkCatchChallenge(pokeball, battle, caught_pokemon)
    #Caught in 1 try
    if battle.balls_thrown == 1
      $Trainer.complete_challenge(:catch_first_try)
    end

    #Catching at full health
    if caught_pokemon.hp == caught_pokemon.totalhp
      $Trainer.complete_challenge(:catch_full_health)
    end

    #Without receiving any damage
    if battle.damage_received ==0
      $Trainer.complete_challenge(:catch_no_damage)
    end

    if pokeball == :PREMIERBALL
      $Trainer.complete_challenge(:catch_premierball)
    end
  end
end
