OW_BEHAVIOR_MOVE_ROUTES = {
  :roaming => {
    :look_around => [
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],

    :still_teleport =>
      [
        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
        RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
        RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),

        RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::Random),
        RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
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

    :random_dive => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [3]),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::Random),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::TurnRandom),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [PUDDLE_ANIMATION_ID]),
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

  },

  :noticed => {
    :shy => [
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::TurnTowardPlayer),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :teleport_away => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::PlayAnimation, [TELEPORT_ANIMATION_ID]),
      RPG::MoveCommand.new(PBMoveRoute::TurnTowardPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :flee => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [200]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [150]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::AwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ],
    :flee_flying => [
      RPG::MoveCommand.new(PBMoveRoute::ChangeFreq, [6]),
      RPG::MoveCommand.new(PBMoveRoute::TurnAwayFromPlayer),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [200]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [150]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [100]),
      RPG::MoveCommand.new(PBMoveRoute::UpperLeft),
      RPG::MoveCommand.new(PBMoveRoute::Opacity, [0]),
      RPG::MoveCommand.new(PBMoveRoute::Script, ["self.despawn"]),
      RPG::MoveCommand.new(PBMoveRoute::End)
    ]
  }
}