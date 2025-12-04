class Trainer
  attr_accessor :pokenav
end

class Pokenav
  AVAILABLE_APPS = { :MAP => "Map",
                     :CONTACTS => "Contacts",
                     :JUKEBOX => "Jukebox", }

  def initialize
    @installed_apps = []
  end

  def install_app(app_id)
    return unless AVAILABLE_APPS.keys.include?(app_id)
    @installed_apps << app_id
    app_name = AVAILABLE_APPS[app_id]
    pbMEPlay("match_call")
    pbMessage(_INTL("The \\C[3]{1} App\\C[0] was installed in the PokéNav!",app_name))
  end
end