def isPlayerMale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
end

def isPlayerFemale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_FEMALE
end

def getPlayerGenderId()
  return pbGet(VAR_TRAINER_GENDER)
end


def isPostgame?()
  return $game_switches[SWITCH_BEAT_THE_LEAGUE]
end

def isPlayerBirthDay?
  return unless $Trainer.birth_day && $Trainer.birth_month
  current_date = Time.now
  return current_date.day == $Trainer.birth_day && current_date.month == $Trainer.birth_month
end