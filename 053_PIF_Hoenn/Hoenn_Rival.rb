# frozen_string_literal: true
HOENN_RIVAL_M_EVENT_NAME = "HOENN_RIVAL_M"
HOENN_RIVAL_APPEARANCE_M = TrainerAppearance.new(5,
                                                 HAT_BRENDAN,
                                                 CLOTHES_BRENDAN,
                                                 getFullHairId(HAIR_BRENDAN, 3),
                                                 0, 0, 0)

HOENN_RIVAL_F_EVENT_NAME = "HOENN_RIVAL_F"
HOENN_RIVAL_APPEARANCE_F = TrainerAppearance.new(5,
                                                 HAT_MAY,
                                                 CLOTHES_MAY,
                                                 getFullHairId(HAIR_MAY, 3),
                                                 0, 0, 0)

class Sprite_Character
  alias PIF_typeExpert_checkModifySpriteGraphics checkModifySpriteGraphics

  def checkModifySpriteGraphics(character)
    PIF_typeExpert_checkModifySpriteGraphics(character)
    return if character == $game_player
    setSpriteToAppearance(HOENN_RIVAL_APPEARANCE_M) if character.name == HOENN_RIVAL_M_EVENT_NAME
    setSpriteToAppearance(HOENN_RIVAL_APPEARANCE_F) if character.name == HOENN_RIVAL_F_EVENT_NAME
  end
end
