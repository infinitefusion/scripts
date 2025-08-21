# Download secret bases from other players
# Loads them into the world

# todo: only load max 5
class SecretBaseLoader
  def initialize
    @importer = SecretBaseImporter.new
  end

  def load_visitor_bases
    all_bases = @importer.load_bases # array of VisitorSecretBase
    $game_temp.visitor_secret_bases = all_bases
  end

end

class Game_Temp
  attr_accessor :visitor_secret_bases
end


def setupAllSecretBaseEntrances
  $PokemonTemp.pbClearTempEvents

  if $Trainer && $Trainer.secretBase && $game_map.map_id == $Trainer.secretBase.outside_map_id
    setupSecretBaseEntranceEvent($Trainer.secretBase)
  end

  if $game_temp.visitor_secret_bases && !$game_temp.visitor_secret_bases.empty?
    $game_temp.visitor_secret_bases.each do |base|
      if $game_map.map_id == base.outside_map_id
        setupSecretBaseEntranceEvent(base)
      end
    end
  end
end
# Called on map load
def setupSecretBaseEntranceEvent(secretBase)
  warpPosition = secretBase.outside_entrance_position
  echoln secretBase.outside_entrance_position

  entrancePosition = [warpPosition[0], warpPosition[1] - 1]
  case secretBase.biome_type
  when :TREE
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_TREE
  when :CAVE
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_CAVE
  else
    template_event_id = TEMPLATE_EVENT_SECRET_BASE_ENTRANCE_CAVE
  end
  event = $PokemonTemp.createTempEvent(template_event_id, $game_map.map_id, entrancePosition)
  event.refresh

end

Events.onMapSceneChange += proc { |_sender, e|
  next unless $PokemonTemp.tempEvents.empty?
  setupAllSecretBaseEntrances
}