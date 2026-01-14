#===============================================================================
#
#===============================================================================
class PokemonChallenges_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    challenges = $Trainer.challenges.values
    @scene.pbStartScene(challenges)
    @scene.pbScene
    @scene.pbEndScene
  end
end


