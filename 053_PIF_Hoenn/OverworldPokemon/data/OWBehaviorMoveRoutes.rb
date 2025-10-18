OW_BEHAVIOR_MOVE_ROUTES = {
  :roaming => {
    :still_teleport =>
      [
        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
        RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),

        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
        RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
        RPG::MoveCommand.new(PBMoveRoute::End)
      ],

    :random_burrow => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [DUST_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)

    ],

  :random_vanish => [
    RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
    RPG::MoveCommand.new(PBMoveRoute::Random),
    RPG::MoveCommand.new(PBMoveRoute::Random),
    RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
    RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
    RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
    RPG::MoveCommand.new(PBMoveRoute::Random),
    RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
    RPG::MoveCommand.new(PBMoveRoute::Wait, [2]),
    RPG::MoveCommand.new(PBMoveRoute::Opacity, [255]),
    RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
    RPG::MoveCommand.new(PBMoveRoute::End)

  ],

  }

}