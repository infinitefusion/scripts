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
  attr_accessor :darkMode
  AVAILABLE_APPS = {
    # Starting apps
    :QUESTS => _INTL("Quests"),
    :MAP => _INTL("Map"),
    :DAYNIGHT => _INTL("Toggle Dark/Light"),
    :REARRANGE => _INTL("Rearrange"),

    # Unlockable apps
    :CONTACTS => _INTL("Contacts"), # obtained after rematch quest
    :JUKEBOX => _INTL("Jukebox"), # obtained at devon corp
    :WEATHER => _INTL("Weather"), # obtained at weather institute
    :POKERADAR => _INTL("PokéRadar"), # given by the rival somewhere?
    :POKECHALLENGE => _INTL("PokéChallenge"),
  }

  def initialize
    @installed_apps = [:MAP, :QUESTS, :DAYNIGHT, :REARRANGE]
    @last_opened_challenges = nil
  end

  def install_app(app_id)
    return unless Pokenav::AVAILABLE_APPS.keys.include?(app_id)
    @installed_apps << app_id
    app_name = AVAILABLE_APPS[app_id]
    pbMEPlay("match_call")
    pbMessage(_INTL("The \\C[3]{1} App\\C[0] was installed in the PokéNav!", app_name))
  end

  def has_app(app_id)
    return @installed_apps.include?(app_id)
  end
end

class PokemonPokegearScreen

  def update_commands
    commands = []
    $Trainer.pokenav.installed_apps.each do |app|
      commands << [app.to_s, Pokenav::AVAILABLE_APPS[app]]
    end
    return commands
  end
  def pbStartScreen
    $Trainer.pokenav = Pokenav.new unless $Trainer.pokenav
    commands = update_commands
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      commands = update_commands  #in case they're reordered
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
      elsif chosen == :REARRANGE
        @scene.rearrange_order
      elsif chosen == :DAYNIGHT
        toggleDarkMode

        # elsif cmdPhone>=0 && cmd==cmdPhone
        #   pbFadeOutIn {
        #     PokemonPhoneScene.new.start
        #   }
      end
    end
    @scene.pbEndScene
  end

  def toggleDarkMode
    pbSEPlay("GUI storage show party panel")
    $Trainer.pokenav.darkMode = false if $Trainer.pokenav.darkMode.nil?
    $Trainer.pokenav.darkMode = !$Trainer.pokenav.darkMode
    @scene.reloadBackground
  end
end
