class Trainer
  attr_accessor :pokenav

  def install_app(app_id)
    @pokenav = Pokenav.new unless $Trainer.pokenav
    @pokenav.install_app(app_id)
  end
end

class Pokenav
  attr_accessor :installed_apps
  attr_accessor :last_opened_challenges #date

  AVAILABLE_APPS = {
    # Starting apps
    :QUESTS => _INTL("Quests"),
    :MAP => _INTL("Map"),

    # Unlockable apps
    :CONTACTS => _INTL("Contacts"), # obtained after rematch quest
    :JUKEBOX => _INTL("Jukebox"), # obtained at devon corp
    :WEATHER => _INTL("Weather"), # obtained at weather institute
    :POKERADAR => _INTL("PokéRadar"), # given by the rival somewhere?
    :POKECHALLENGE => _INTL("PokéChallenge"),
  }

  def initialize
    @installed_apps = [:MAP, :QUESTS]
    @last_opened_challenges = nil
  end

  def install_app(app_id)
    return unless Pokenav::AVAILABLE_APPS.keys.include?(app_id)
    @installed_apps << app_id
    app_name = AVAILABLE_APPS[app_id]
    pbMEPlay("match_call")
    pbMessage(_INTL("The \\C[3]{1} App\\C[0] was installed in the PokéNav!", app_name))
  end
end

class PokemonPokegearScreen
  def pbStartScreen
    $Trainer.pokenav = Pokenav.new unless $Trainer.pokenav
    commands = []
    $Trainer.pokenav.installed_apps.each do |app|
      commands << [app.to_s, Pokenav::AVAILABLE_APPS[app]]
    end
    echoln commands

    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      chosen = commands[cmd][0].to_sym
      echoln chosen
      if cmd < 0
        break
      elsif chosen == :MAP
        pbShowMap(-1, false)
      elsif chosen == :JUKEBOX
          pbFadeOutIn {
            scene = PokemonJukebox_Scene.new
            screen = PokemonJukeboxScreen.new(scene)
            screen.pbStartScreen
          }
      elsif chosen == :QUESTS
        pbQuestlog()
      elsif chosen == :CONTACTS
        next
      elsif chosen == :WEATHER
        pbWeatherMap
      elsif chosen == :POKECHALLENGE
        openChallengeApp

        # elsif cmdPhone>=0 && cmd==cmdPhone
        #   pbFadeOutIn {
        #     PokemonPhoneScene.new.start
        #   }
        # elsif cmdJukebox>=0 && cmd==cmdJukebox
        #   pbFadeOutIn {
        #     scene = PokemonJukebox_Scene.new
        #     screen = PokemonJukeboxScreen.new(scene)
        #     screen.pbStartScreen
        #   }
      end
    end
    @scene.pbEndScene
  end
end
