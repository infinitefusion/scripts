def showQuestMap
  scene = QuestMap.new
  return scene.flydata
end

class QuestMap < BetterRegionMap
  QUEST_ICON_PATH = "Graphics/Pictures/map/quest_icon"

  def initialize
    @quests = {}
    super(nil, true, false, false, nil, nil, false)
  end

  def initialize_quests_locations
    $Trainer.quests.each do |quest|
      next if quest.completed
      position = [0, 0] # default
      if quest.location_map_id
        position = getTownMapFlyCoordinates(quest.location_map_id)
      end
      quests_at_location = @quests[position]
      quests_at_location = [] if quests_at_location.nil?
      quests_at_location << quest
      @quests[position] = quests_at_location
    end
  end

  def add_map_icons
    initialize_quests_locations
    @quests.each_key do |position|
      add_map_icon_at_position(position, position, QUEST_ICON_PATH)
    end
  end

  def update_text
    current_position = [$PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]]
    quests_at_location = @quests[current_position]
    nb_quests_at_position = 0
    nb_quests_at_position = @quests[current_position].length if quests_at_location
    location = @data[2].find do |e|
      e[0] == $PokemonGlobal.regionMapSel[0] &&
        e[1] == $PokemonGlobal.regionMapSel[1]
    end

    text = ""
    text = location[2] if location

    nb_quests_text = ""
    if nb_quests_at_position > 1
      nb_quests_text = _INTL("{1} accepted quests", nb_quests_at_position)
    elsif nb_quests_at_position > 0
      nb_quests_text = _INTL("{1} accepted quests", nb_quests_at_position)
    end
    @sprites["txt"].draw([
                           [pbGetMessage(MessageTypes::RegionNames, @region), 16, 0, 0,
                            Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [text, 16, 344, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [nb_quests_text, 496, 344, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                         ], true)
  end

end