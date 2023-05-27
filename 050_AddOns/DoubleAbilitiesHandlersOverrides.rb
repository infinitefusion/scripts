
module BattleHandlers
  #
  #   Speed calculation
  #

  def self.triggerSpeedCalcAbility(ability, battler, mult)
    ability1 = ability
    ability2 = battler.ability2
    calculateAbilitySpeedMultiplier(ability1, battler, mult)
    if $game_switches[SWITCH_DOUBLE_ABILITIES]
      calculateAbilitySpeedMultiplier(ability2, battler, mult)
    end
    return mult
  end

  def self.calculateAbilitySpeedMultiplier(ability, battler, mult)
    ret = SpeedCalcAbility.trigger(ability, battler, mult)
    return (ret != nil) ? ret : mult
  end

  #
  #   Weight calculation
  #
  def self.triggerWeightCalcAbility(ability, battler, w)
    ability1 = ability
    ability2 = battler.ability2

    calculateWeightAbilityMultiplier(ability1, battler, mult)
    if $game_switches[SWITCH_DOUBLE_ABILITIES]
      calculateWeightAbilityMultiplier(ability2, battler, mult)
    end
    return mult

  end

  def self.calculateWeightAbilityMultiplier(ability, battler, w)
    ret = WeightCalcAbility.trigger(ability, battler, w)
    return (ret != nil) ? ret : w
  end


  def self.triggerEOREffectAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2

    EOREffectAbility.trigger(ability1,battler,battle)
    EOREffectAbility.trigger(ability2,battler,battle)
  end

  def self.triggerEORGainItemAbility(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2

    EORGainItemAbility.trigger(ability1,battler,battle)
    EORGainItemAbility.trigger(ability2,battler,battle)
  end

  def self.triggerCertainSwitchingUserAbility(ability,switcher,battle)
    ability1 = ability
    ability2 = battler.ability2

    ret = CertainSwitchingUserAbility.trigger(ability1,switcher,battle) ||  CertainSwitchingUserAbility.trigger(ability2,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerCertainSwitchingUserAbility(ability,switcher,battle)
    ability1 = ability
    ability2 = battler.ability2

    ret = CertainSwitchingUserAbility.trigger(ability1,switcher,battle) || CertainSwitchingUserAbility.trigger(ability2,switcher,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerTrappingTargetAbility(ability,switcher,bearer,battle)
    ability1 = ability
    ability2 = battler.ability2
    ret = TrappingTargetAbility.trigger(ability1,switcher,bearer,battle) || TrappingTargetAbility.trigger(ability2,switcher,bearer,battle)
    return (ret!=nil) ? ret : false
  end

  def self.triggerAbilityOnSwitchIn(ability,battler,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnSwitchIn.trigger(ability1,battler,battle)
    AbilityOnSwitchIn.trigger(ability2,battler,battle)
  end

  def self.triggerAbilityOnSwitchOut(ability,battler,endOfBattle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnSwitchOut.trigger(ability1,battler,endOfBattle)
    AbilityOnSwitchOut.trigger(ability2,battler,endOfBattle)
  end

  def self.triggerAbilityChangeOnBattlerFainting(ability,battler,fainted,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityChangeOnBattlerFainting.trigger(ability1,battler,fainted,battle)
    AbilityChangeOnBattlerFainting.trigger(ability2,battler,fainted,battle)

  end

  def self.triggerAbilityOnBattlerFainting(ability,battler,fainted,battle)
    ability1 = ability
    ability2 = battler.ability2
    AbilityOnBattlerFainting.trigger(ability1,battler,fainted,battle)
    AbilityOnBattlerFainting.trigger(ability2,battler,fainted,battle)
  end


  def self.triggerRunFromBattleAbility(ability,battler)
    ability1 = ability
    ability2 = battler.ability2
    ret = RunFromBattleAbility.trigger(ability1,battler) || RunFromBattleAbility.trigger(ability2,battler)
    return (ret!=nil) ? ret : false
  end
end