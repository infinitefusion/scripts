#===============================================================================
#
#===============================================================================
class PokeRadarAppScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end

end


