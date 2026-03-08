#===============================================================================
#
#===============================================================================
class ContactsAppScreen
  def initialize(scene)
    @scene = scene
  end

  UNLISTABLE_TRAINER_TYPES = [:TEAM_AQUA_GRUNT_M, :TEAM_AQUA_GRUNT_F,
                              :TEAM_MAGMA_GRUNT_M, :TEAM_MAGMA_GRUNT_F,
                              :TEAM_MAGMAQUA_GRUNT_M, :TEAM_MAGMAQUA_GRUNT_F,
                              :TEAM_AQUA_EXEC_M, :TEAM_AQUA_EXEC_F,
                              :TEAM_MAGMA_EXEC_M, :TEAM_MAGMA_EXEC_F,
                              :TEAM_AQUA_BOSS, :TEAM_MAGMA_BOSS
  ]

  def pbStartScreen(main_menu_scene)
    @main_menu_scene = main_menu_scene
    @scene.pbStartScene(self)
    @scene.pbScene
    @scene.pbEndScene
  end

  def list_contacts
    contacts_list_by_location = {}
    $PokemonGlobal.battledTrainers.each do |id, trainer|
      location = trainer.location
      contacts_list_by_location[location] ||= []
      contacts_list_by_location[location] << trainer
    end
    contacts_list_by_location.each_value do |trainer_array|
      trainer_array.sort_by! { |t| t.trainerName }
    end
    return contacts_list_by_location
  end

  def can_be_listed(trainer)
    trainerType = trainer.trainerType
    return false if UNLISTABLE_TRAINER_TYPES.include?(trainerType)
    return true
  end

  def view_trainer_page(trainer_id)
    trainer= getRebattledTrainerFromKey(trainer_id)
    if trainer
      pbFadeOutIn {
        scene = ContactsAppInfoPageScene.new
        screen = ContactsAppInfoPageScreen.new
        screen.pbStartScreen(scene)
      }
    else
      pbSEPlay("buzzer", 80)
      pbWait(4)
    end
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


  def pbSummary(list, index)
    visibleSprites = pbFadeOutAndHide(@sprites) { pbUpdate }
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    @sprites["list"].index = screen.pbStartScreen(list, index ,false)
    pbFadeInAndShow(@sprites, visibleSprites) { pbUpdate }
  end

end


