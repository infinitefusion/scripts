def showQuestMap
  QuestMap.new
end

class QuestMap < BetterRegionMap
  attr_reader :reopen_map
  QUEST_SIDE_ICON_PATH = "Graphics/Pictures/map/quest_icon"
  QUEST_MAIN_ICON_PATH = "Graphics/Pictures/map/quest_icon_main"

  def initialize
    @quests = {}
    @spots = {}
    @popup = nil
    @snapping = false
    @previous_position = [0, 0]
    super(nil, true, false, false, nil, nil, false)
  end

  def after_init_graphics
    @window["player"].visible = false
    on_hover($PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1])
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
      @spots[position] = quests_at_location # Unused, but the map checks positions in there to see if it should snap to a new location
    end
  end

  def add_map_icons
    initialize_quests_locations
    icon_path = QUEST_SIDE_ICON_PATH
    @quests.each_key do |position|
      quests_list = @quests[position]
      quests_list.each do |quest|
        if quest.type == :MAIN_QUEST
          icon_path = QUEST_MAIN_ICON_PATH
          break
        else
          icon_path = QUEST_SIDE_ICON_PATH
        end
      end
      add_map_icon_at_position(position, position, icon_path)
    end
  end

  def on_hover(x, y)
    echoln quests_at_pos
    if quests_at_pos && !quests_at_pos.empty?
      snap_to_position(x, y)
      show_popup(quests_at_pos)
    else
      hide_popup
    end
  end

  def on_start_moving
  end

  def on_stop_moving
    return if @snapping
    x = $PokemonGlobal.regionMapSel[0]
    y = $PokemonGlobal.regionMapSel[1]
    if @quests.has_key?([x, y])
      on_hover(x, y)
      return
    end

    nearby_quest = find_quest_near_coordinates(x, y, 2)
    if nearby_quest
      @snapping = true
      new_x, new_y = nearby_quest
      if [new_x, new_y] != @position_before_moving
        snap_to_position(new_x, new_y)
        on_hover(new_x, new_y)
      end
      @snapping = false
    end
  end

  def find_quest_near_coordinates(current_x, current_y, radius)
    closest = nil
    min_distance = Float::INFINITY
    for new_x in current_x - radius..current_x + radius
      for new_y in current_y - radius..current_y + radius
        if @quests.has_key?([new_x, new_y])
          distance = Math.sqrt((new_x - current_x) ** 2 + (new_y - current_y) ** 2)
          if distance < min_distance
            min_distance = distance
            closest = [new_x, new_y]
          end
        end
      end
    end
    return closest
  end

  def on_click(x, y)
    return unless @popup
    quest = @popup.run
    if quest
      @popup = nil
      @sprites.visible = false
      @window.visible = false
      Questlog.new(open_quest: quest, from_map: true)
      @sprites.visible = true
      @window.visible = true
      @viewport.visible = true
      @viewport2.visible = true
      @mapvp.visible = true
      @mapoverlayvp.visible = true
      Graphics.update
      x, y = $PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]
      on_hover(x, y)
      #@popup&.set_selected(true)
      @popup&.refresh
    end
  end

  def show_popup(quests)
    location_name = get_current_location_name
    return if @popup && @popup.quests == quests
    hide_popup
    on_right_half = @sprites["cursor"].x > (Graphics.width / 2)
    @popup = QuestMapPopup.new(quests, on_right_half, @viewport2, location_name)
    pbWait(4)
  end

  def should_exit_confirm?
    return false
  end

  def on_exit_main
    @reopen_map = false
    if @switch_to_questlog
      @switch_to_questlog = false
      @reopen_map = true
    end
  end

  def should_exit_cancel?
    return true if @switch_to_questlog
    return false if @popup && @popup.panel_active
    return Input.trigger?(Input::B)
  end

  def on_update
    if Input.trigger?(Input::L) || Input.trigger?(Input::R)
      pbSEPlay("GUI storage show party panel")
      $Trainer.pokenav.last_opened_quest_mode = :LIST
      @switch_to_questlog = true
    end
  end

  def hide_popup
    return unless @popup
    @popup.animate_out
    @popup.dispose
    @popup = nil
  end

  def dispose
    hide_popup
    super
  end

  def update_text_at_location(location)
    current_position = [$PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1]]
    quests_at_location = @quests[current_position]
    nb_quests_at_position = 0
    nb_quests_at_position = @quests[current_position].length if quests_at_location
    text = ""
    text = location[2] if location

    nb_quests_text = ""
    if nb_quests_at_position > 1
      nb_quests_text = _INTL("{1} quests in progress", nb_quests_at_position)
    elsif nb_quests_at_position > 0
      nb_quests_text = _INTL("{1} quest in progress", nb_quests_at_position)
    end
    @sprites["txt"].draw([
                           [_INTL("Quest Log"), 24, -8, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [_INTL("L/R : LIST"), 360, -8, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [text, 16, 344, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                           [nb_quests_text, 496, 344, 1, Color.new(255, 255, 255), Color.new(0, 0, 0)],
                         ], true)
    on_hover($PokemonGlobal.regionMapSel[0], $PokemonGlobal.regionMapSel[1])
  end

  def open_quest_detail(quest)
    dispose
    Questlog.new(open_quest: quest)
  end
end