class ContactsAppInfoPageScreen

  def pbStartScreen(scene, trainer)
    @scene = scene
    @scene.pbStartScene(self, trainer)
    @scene.pbScene
    @scene.pbEndScene
  end

  def view_trainer_team(trainer_id)
    trainer= getRebattledTrainerFromKey(trainer_id)
    if trainer
      team = trainer.currentTeam
      pbFadeOutIn {
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene)
        screen.pbStartScreen(team,0)
      }
    else
      pbSEPlay("buzzer", 80)
      pbWait(4)
    end
  end
end