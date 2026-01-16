
def checkTrainerRematchChallenges
  $Trainer.complete_challenge(:rematch_trainer)
end

class PokeBattle_Battler
  def checkChallengesAfterTurn()
    @battle.eachBattler do |battler|
      if battler.pbOwnedByPlayer?

      else
        #       # 1 HP left check
        if battler.hp == 1
          $Trainer.complete_challenge(:battle_enemy_1_hp)
        end

      end
    end
  end



  alias challenge_pbFlinch pbFlinch
  def pbFlinch(_user=nil)
    challenge_pbFlinch(_user)
    unless _user&.pbOwnedByPlayer?
      $Trainer.complete_challenge(:battle_flinch)
    end
  end

end

class PokeBattle_Move
  alias challenge_pbInflictHPDamage pbInflictHPDamage
  def pbInflictHPDamage(target)
    challenge_pbInflictHPDamage(target)

    return if target.pbOwnedByPlayer?
    #Not very effective 1 hit KO
    if target.fainted? &&
      target.damageState.initialHP == target.totalhp &&
      Effectiveness.not_very_effective?(target.damageState.typeMod)
      $Trainer.complete_challenge(:defeat_1_not_very_effective)
    end
  end
end

