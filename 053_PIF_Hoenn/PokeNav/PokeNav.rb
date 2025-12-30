class Trainer
  attr_accessor :pokenav
end

class Pokenav
  attr_accessor :installed_apps
  AVAILABLE_APPS = {
    # Starting apps
    :QUESTS => _INTL("Quests"),
    :MAP => _INTL("Map"),

    # Unlockable apps
    :CONTACTS => _INTL("Contacts"), # obtained after rematch quest
    :JUKEBOX => _INTL("Jukebox"),
    :WEATHER => _INTL("Weather"), # obtained at weather institute
    :POKERADAR => _INTL("Pokeradar"), # obtained at devon corp?
    :STATISTICS => _INTL("Statistics"),
  }

  def initialize
    @installed_apps = [:MAP, :QUESTS]
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
