##=============================================================================
##  Easy Questing System - Refactored with Extensible Mode System
##  Original by M3rein
#   Refactored using by Claude
#   Adapted for Pokemon Infinite Fusion by chardub
##=============================================================================
##  Main entry point for the quest log
##=============================================================================

def pbQuestlog
  ensure_quests_repaired
  Questlog.new
end

def ensure_quests_repaired
  return if $Trainer.quests_repaired
  fix_quest_ids
  $Trainer.quests_repaired = true
end

##=============================================================================
##  QuestSprite - Sprite class for quest list items
##=============================================================================

class QuestSprite < IconSprite
  attr_accessor :quest
end

##=============================================================================
##  QuestMode - Base class for quest filtering modes
##=============================================================================

class QuestMode
  attr_reader :name, :button_text

  def initialize(name, button_text)
    @name = name
    @button_text = button_text
  end

  # Override this method to define filtering logic
  def filter_quests(all_quests)
    raise NotImplementedError, "Subclasses must implement filter_quests"
  end

  # Override to customize empty message
  def empty_message
    "No quests"
  end

  # Override to customize title
  def title
    @name
  end
end

##=============================================================================
##  Built-in Quest Modes
##=============================================================================

class OngoingQuestMode < QuestMode
  def initialize
    super("Ongoing Quests", "Ongoing")
  end

  def filter_quests(all_quests)
    all_quests.select { |q| !q.completed }
  end

  def empty_message
    _INTL("No ongoing quests")
  end
end

class CompletedQuestMode < QuestMode
  def initialize
    super("Completed Quests", "Completed")
  end

  def filter_quests(all_quests)
    all_quests.select { |q| q.completed }
  end

  def empty_message
    _INTL("No completed quests")
  end
end

# Example: Quest modes by status/priority
class HighPriorityQuestMode < QuestMode
  def initialize
    super("High Priority Quests", "High Priority")
  end

  def filter_quests(all_quests)
    all_quests.select { |q| !q.completed && q.respond_to?(:priority) && q.priority == :high }
  end

  def empty_message
    _INTL("No high priority quests")
  end
end

class MainQuestMode < QuestMode
  def initialize
    super("Main Story Quests", "Main Story")
  end

  def filter_quests(all_quests)
    all_quests.select { |q| !q.completed && q.respond_to?(:quest_type) && q.quest_type == :main }
  end

  def empty_message
    _INTL("No main story quests")
  end
end

class SideQuestMode < QuestMode
  def initialize
    super("Side Quests", "Side Quests")
  end

  def filter_quests(all_quests)
    all_quests.select { |q| !q.completed && q.respond_to?(:quest_type) && q.quest_type == :side }
  end

  def empty_message
    _INTL("No side quests")
  end
end

class LocationQuestMode < QuestMode
  attr_reader :location

  def initialize(location)
    @location = location
    super("#{location} Quests", location)
  end

  def filter_quests(all_quests)
    all_quests.select { |q| !q.completed && q.location.include?(@location) }
  end

  def empty_message
    _INTL("No quests in {1}", @location)
  end
end

##=============================================================================
##  Questlog - Main quest interface controller (Refactored)
##=============================================================================

class Questlog
  # Scene constants
  SCENE_MAIN = 0
  SCENE_LIST = 1
  SCENE_DETAIL = 2

  # UI constants
  MAX_VISIBLE_QUESTS = 6
  FADE_SPEED = 32
  ANIMATION_FRAMES = 12
  CHAR_ANIMATION_INTERVAL = 6

  def initialize
    initialize_data
    initialize_modes
    initialize_viewport
    create_sprites
    animate_intro
    main_loop
    cleanup
  end

  private

  ##---------------------------------------------------------------------------
  ##  Initialization
  ##---------------------------------------------------------------------------

  def initialize_data
    $Trainer.quests = [] if $Trainer.quests.nil?

    @page = 0
    @main_menu_index = 0
    @quest_list_menu_index = 0
    @scene = SCENE_MAIN
    @current_mode = nil
    @box = 0          # Visible quest index (0-5)
    @frame = 0
    @filtered_quests = []

    fix_broken_TR_quests
  end

  def initialize_modes
    # Register all available modes here
    @modes = [
      OngoingQuestMode.new,
      CompletedQuestMode.new,
    # Add more modes as needed:
    # MainQuestMode.new,
    # SideQuestMode.new,
    # HighPriorityQuestMode.new,
    ]

    # You can dynamically add location-based modes:
    # @modes << LocationQuestMode.new("Cerulean City")
    # @modes << LocationQuestMode.new("Viridian Forest")
  end

  def initialize_viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
  end

  def create_sprites
    create_main_bitmap
    create_background
    create_mode_buttons
    draw_main_text
  end

  def create_main_bitmap
    @sprites["main"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["main"].z = 1
    @sprites["main"].opacity = 0
    @main = @sprites["main"].bitmap
    pbSetSystemFont(@main)
  end

  def create_background
    @sprites["bg0"] = IconSprite.new(0, 0, @viewport)
    bg_path = $Trainer.pokenav.darkMode ?
                "Graphics/Pictures/Pokegear/bg_dark" :
                "Graphics/Pictures/Pokegear/bg"
    @sprites["bg0"].setBitmap(bg_path)
    @sprites["bg0"].opacity = 0
  end

  def create_mode_buttons
    @modes.size.times do |i|
      @sprites["btn#{i}"] = IconSprite.new(0, 0, @viewport)
      @sprites["btn#{i}"].setBitmap("Graphics/Pictures/eqi/quest_button")
      @sprites["btn#{i}"].x = 84
      @sprites["btn#{i}"].y = 130 + 56 * i
      @sprites["btn#{i}"].src_rect.height = (@sprites["btn#{i}"].bitmap.height / 2).round
      @sprites["btn#{i}"].src_rect.y = i == 0 ? (@sprites["btn#{i}"].bitmap.height / 2).round : 0
      @sprites["btn#{i}"].opacity = 0
    end
  end

  def draw_main_text
    pbDrawOutlineText(@main, 0, 2, 512, 384, "Quest Log",
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    # Draw button labels and quest counts
    @modes.each_with_index do |mode, i|
      quest_count = mode.filter_quests($Trainer.quests).size
      y_pos = 142 + (56 * i)
      pbDrawOutlineText(@main, 0, y_pos, 512, 384,
                        _INTL("{1}: {2}", mode.button_text, quest_count),
                        Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    end
  end

  def animate_intro
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED if i < 8

      # Fade in all mode buttons
      @modes.size.times do |j|
        @sprites["btn#{j}"].opacity += FADE_SPEED if i > 3
      end

      @sprites["main"].opacity += 64 if i > 7
    end
  end

  ##---------------------------------------------------------------------------
  ##  Main Loop
  ##---------------------------------------------------------------------------

  def main_loop
    @frame = 0

    loop do
      @frame += 1
      Graphics.update
      Input.update

      break if handle_input

      @frame = 0 if @frame == 18
    end
  end

  def handle_input
    case @scene
    when SCENE_MAIN
      return handle_main_input
    when SCENE_LIST
      handle_list_input
    when SCENE_DETAIL
      handle_detail_input
    end
    return false
  end

  def handle_main_input
    return true if Input.trigger?(Input::B)

    if Input.trigger?(Input::C)
      show_quest_list(@main_menu_index)
    elsif Input.press?(Input::DOWN)
      switch_button(:DOWN)
    elsif Input.trigger?(Input::UP)
      switch_button(:UP)
    end

    false
  end

  def handle_list_input
    if Input.trigger?(Input::B)
      return_to_main
    elsif Input.press?(Input::DOWN)
      move_selection(:DOWN)
    elsif Input.press?(Input::UP)
      move_selection(:UP)
    elsif Input.trigger?(Input::C)
      show_quest_detail
    end

    animate_arrows
  end

  def handle_detail_input
    if Input.trigger?(Input::B)
      show_quest_list(@modes.index(@current_mode))
    end

    animate_character if [6, 12, 18].include?(@frame)
  end

  ##---------------------------------------------------------------------------
  ##  Navigation
  ##---------------------------------------------------------------------------

  def switch_button(dir)
    max_index = @modes.size - 1

    if dir == :DOWN
      return if @main_menu_index == max_index
      @sprites["btn#{@main_menu_index}"].src_rect.y = 0
      @main_menu_index += 1
      @sprites["btn#{@main_menu_index}"].src_rect.y = (@sprites["btn#{@main_menu_index}"].bitmap.height / 2).round
    else
      return if @main_menu_index == 0
      @sprites["btn#{@main_menu_index}"].src_rect.y = 0
      @main_menu_index -= 1
      @sprites["btn#{@main_menu_index}"].src_rect.y = (@sprites["btn#{@main_menu_index}"].bitmap.height / 2).round
    end
  end

  def move_selection(dir)
    return if @filtered_quests.empty?

    if dir == :DOWN
      return if @quest_list_menu_index == @filtered_quests.size - 1

      deselect_current_quest
      @quest_list_menu_index += 1
      @box += 1
      @box = 5 if @box > 5
      select_current_quest

      refresh_quest_list if @box == 5
    else
      return if @quest_list_menu_index == 0

      deselect_current_quest
      @quest_list_menu_index -= 1
      @box -= 1
      @box = 0 if @box < 0
      select_current_quest

      refresh_quest_list if @box == 0
    end

    pbWait(4)
  end

  def deselect_current_quest
    @sprites["quest#{@box}"].src_rect.y = 0 if @sprites["quest#{@box}"]
  end

  def select_current_quest
    if @sprites["quest#{@box}"]
      @sprites["quest#{@box}"].src_rect.y = (@sprites["quest#{@box}"].bitmap.height / 2).round
    end
  end

  ##---------------------------------------------------------------------------
  ##  Scene Transitions
  ##---------------------------------------------------------------------------

  def return_to_main
    pbWait(1)
    fade_to_main
    reset_list_state
    redraw_main_screen
    animate_main_return
  end

  def fade_to_main
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      fade_sprites_out(i)
    end

    dispose_list_sprites
    clear_bitmaps
  end

  def fade_sprites_out(index)
    @sprites["main"].opacity -= FADE_SPEED if @sprites["main"]
    @sprites["bg0"].opacity += FADE_SPEED if @sprites["bg0"].opacity < 255

    if index > 3
      @sprites["bg1"].opacity -= FADE_SPEED if @sprites["bg1"]
      @sprites["bg2"].opacity -= FADE_SPEED if @sprites["bg2"]
      @sprites["pager"].opacity -= FADE_SPEED if @sprites["pager"]
      @sprites["pager2"].opacity -= FADE_SPEED if @sprites["pager2"]
    end

    @sprites["char"].opacity -= FADE_SPEED if @sprites["char"]
    @sprites["char2"].opacity -= FADE_SPEED if @sprites["char2"]
    @sprites["text"].opacity -= FADE_SPEED if @sprites["text"]
    @sprites["up"].opacity -= FADE_SPEED if @sprites["up"]
    @sprites["down"].opacity -= FADE_SPEED if @sprites["down"]

    fade_quest_sprites
  end

  def fade_quest_sprites
    MAX_VISIBLE_QUESTS.times do |i|
      @sprites["quest#{i}"].opacity -= FADE_SPEED if @sprites["quest#{i}"]
    end
  end

  def dispose_list_sprites
    @sprites["up"].dispose if @sprites["up"]
    @sprites["down"].dispose if @sprites["down"]
  end

  def clear_bitmaps
    @main.clear if @main
    @text.clear if @text
    @text2.clear if @text2
  end

  def reset_list_state
    @scene = SCENE_MAIN
  end

  def redraw_main_screen
    pbDrawOutlineText(@main, 0, 2, 512, 384, _INTL("Quest Log"),
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    @modes.each_with_index do |mode, i|
      quest_count = mode.filter_quests($Trainer.quests).size
      y_pos = 142 + (56 * i)
      pbDrawOutlineText(@main, 0, y_pos, 512, 384,
                        _INTL("{1}: {2}", mode.button_text, quest_count),
                        Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    end
  end

  def animate_main_return
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED if i < 8

      @modes.size.times do |j|
        @sprites["btn#{j}"].opacity += FADE_SPEED if i > 3
      end

      @sprites["main"].opacity += 48 if i > 5
    end
  end

  ##---------------------------------------------------------------------------
  ##  Quest List Display
  ##---------------------------------------------------------------------------

  def show_quest_list(mode_index)
    pbWait(2)
    @page = 0
    @scene = SCENE_LIST
    @current_mode = @modes[mode_index]
    @quest_list_menu_index = 0
    @box = 0

    # Filter quests using the selected mode
    @filtered_quests = @current_mode.filter_quests($Trainer.quests)

    create_arrow_sprites
    fade_to_list
    clear_bitmaps
    display_quest_list
  end

  def create_arrow_sprites
    @sprites["up"] = create_arrow(36, false)
    @sprites["down"] = create_arrow(360, true)
    @sprites["down"].visible = @filtered_quests.size > MAX_VISIBLE_QUESTS
    @sprites["down"].opacity = 0
  end

  def create_arrow(y_pos, flip)
    arrow = IconSprite.new(0, 0, @viewport)
    arrow.setBitmap("Graphics/Pictures/EQI/quest_arrow")
    arrow.zoom_x = 1.25
    arrow.zoom_y = 1.25
    arrow.x = Graphics.width / 2 + (flip ? 21 : 0)
    arrow.y = y_pos
    arrow.z = 2
    arrow.angle = flip ? 180 : 0
    arrow.visible = false
    arrow
  end

  def fade_to_list
    10.times do |i|
      Graphics.update

      if i > 1
        @modes.size.times do |j|
          @sprites["btn#{j}"].opacity -= FADE_SPEED
        end
        @sprites["main"].opacity -= FADE_SPEED
        fade_detail_sprites
      end
    end
  end

  def fade_detail_sprites
    @sprites["bg1"].opacity -= FADE_SPEED if @sprites["bg1"]
    @sprites["bg2"].opacity -= FADE_SPEED if @sprites["bg2"]
    @sprites["pager"].opacity -= FADE_SPEED if @sprites["pager"]
    @sprites["pager2"].opacity -= FADE_SPEED if @sprites["pager2"]
    @sprites["char"].opacity -= FADE_SPEED if @sprites["char"]
    @sprites["char2"].opacity -= FADE_SPEED if @sprites["char2"]
    @sprites["text"].opacity -= FADE_SPEED if @sprites["text"]
    @sprites["text2"].opacity -= FADE_SPEED if @sprites["text2"]
  end

  def display_quest_list
    [@filtered_quests.size, MAX_VISIBLE_QUESTS].min.times do |i|
      create_quest_sprite(i, @filtered_quests[i])
      draw_quest_name(i, @filtered_quests[i])
    end

    if @filtered_quests.empty?
      pbDrawOutlineText(@main, 0, 175, 512, 384, @current_mode.empty_message,
                        pbColor(:WHITE), pbColor(:BLACK), 1)
    end

    pbDrawOutlineText(@main, 0, 2, 512, 384, @current_mode.title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    animate_quest_list
  end

  def create_quest_sprite(index, quest)
    sprite_key = "quest#{index}"
    @sprites[sprite_key] = QuestSprite.new(0, 0, @viewport)
    @sprites[sprite_key].setBitmap("Graphics/Pictures/EQI/quest_button")
    @sprites[sprite_key].quest = quest
    @sprites[sprite_key].x = 94
    @sprites[sprite_key].y = 42 + 52 * index
    @sprites[sprite_key].src_rect.height = (@sprites[sprite_key].bitmap.height / 2).round
    @sprites[sprite_key].src_rect.y = (@sprites[sprite_key].bitmap.height / 2).round if index == @quest_list_menu_index
    @sprites[sprite_key].opacity = 0
  end

  def draw_quest_name(index, quest)
    y_pos = get_cell_y_position(index)
    pbDrawOutlineText(@main, 11, y_pos, 512, 384, quest.name,
                      quest.color, Color.new(0, 0, 0), 1)
  end

  def get_cell_y_position(index)
    56 + (52 * index)
  end

  def animate_quest_list
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["main"].opacity += FADE_SPEED if i < 8
      @sprites["down"].opacity += FADE_SPEED if i > 3

      [@filtered_quests.size, MAX_VISIBLE_QUESTS].min.times do |j|
        @sprites["quest#{j}"].opacity += FADE_SPEED if i > 3
      end
    end
  end

  def refresh_quest_list
    @main.clear if @main

    # Determine which quest should appear in each visible slot
    MAX_VISIBLE_QUESTS.times do |i|
      next if i >= @filtered_quests.size

      # Calculate which quest should appear in this slot
      quest_index = @quest_list_menu_index - @box + i
      quest_index = 0 if quest_index < 0
      quest_index = @filtered_quests.size - 1 if quest_index >= @filtered_quests.size

      # Assign quest to sprite and draw its name
      @sprites["quest#{i}"].quest = @filtered_quests[quest_index]
      draw_quest_name(i, @filtered_quests[quest_index])
    end

    # Update arrow visibility
    @sprites["up"].visible = @quest_list_menu_index > 0
    @sprites["down"].visible = @quest_list_menu_index < @filtered_quests.size - 1

    # Redraw the title
    pbDrawOutlineText(@main, 0, 2, 512, 384, @current_mode.title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
  end

  ##---------------------------------------------------------------------------
  ##  Quest Detail Display
  ##---------------------------------------------------------------------------

  def show_quest_detail
    return if @filtered_quests.empty?

    quest = @filtered_quests[@quest_list_menu_index]
    pbWait(1)

    @scene = SCENE_DETAIL
    create_detail_background
    fade_to_detail
    create_character_sprite(quest)
    draw_quest_details(quest)
    animate_detail_in
  end

  def create_detail_background
    @sprites["bg1"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg1"].setBitmap("Graphics/Pictures/EQI/quest_page1")
    @sprites["bg1"].opacity = 0

    @sprites["pager"] = IconSprite.new(0, 0, @viewport)
    @sprites["pager"].setBitmap("Graphics/Pictures/EQI/quest_pager")
    @sprites["pager"].x = 442
    @sprites["pager"].y = 3
    @sprites["pager"].z = 1
    @sprites["pager"].opacity = 0
  end

  def fade_to_detail
    8.times do
      Graphics.update
      @sprites["up"].opacity -= FADE_SPEED
      @sprites["down"].opacity -= FADE_SPEED
      @sprites["main"].opacity -= FADE_SPEED
      @sprites["bg1"].opacity += FADE_SPEED if @sprites["bg1"]
      @sprites["pager"].opacity = 0 if @sprites["pager"]
      @sprites["char"].opacity -= FADE_SPEED if @sprites["char"]

      fade_quest_list_sprites
    end

    @sprites["up"].dispose
    @sprites["down"].dispose
  end

  def fade_quest_list_sprites
    MAX_VISIBLE_QUESTS.times do |i|
      @sprites["quest#{i}"].opacity -= FADE_SPEED if @sprites["quest#{i}"]
    end
  end

  def create_character_sprite(quest)
    @sprites["char"] = IconSprite.new(0, 0, @viewport)
    @sprites["char"].setBitmap("Graphics/Characters/#{quest.sprite}")
    @sprites["char"].x = 62
    @sprites["char"].y = 130
    @sprites["char"].src_rect.height = (@sprites["char"].bitmap.height / 4).round
    @sprites["char"].src_rect.width = (@sprites["char"].bitmap.width / 4).round
    @sprites["char"].opacity = 0
  end

  def draw_quest_details(quest)
    @main.clear if @main
    @text.clear if @text
    @text2.clear if @text2

    drawTextExMulti(@main, 188, 54, 318, 8, quest.desc,
                    Color.new(255, 255, 255), Color.new(0, 0, 0))
    pbDrawOutlineText(@main, 188, 330, 512, 384, quest.location,
                      Color.new(255, 172, 115), Color.new(0, 0, 0))
    pbDrawOutlineText(@main, 10, -178, 512, 384, quest.name,
                      quest.color, Color.new(0, 0, 0))

    draw_completion_status(quest)
  end

  def draw_completion_status(quest)
    if quest.completed
      pbDrawOutlineText(@main, 8, 250, 512, 384, _INTL("Completed"),
                        pbColor(:LIGHTBLUE), Color.new(0, 0, 0))
    else
      pbDrawOutlineText(@main, 8, 250, 512, 384, _INTL("Not Completed"),
                        pbColor(:LIGHTRED), Color.new(0, 0, 0))
    end
  end

  def animate_detail_in
    10.times do |i|
      Graphics.update
      @sprites["main"].opacity += FADE_SPEED
      @sprites["char"].opacity += FADE_SPEED if i > 1
    end
  end

  ##---------------------------------------------------------------------------
  ##  Animations
  ##---------------------------------------------------------------------------

  def animate_arrows
    return unless @sprites["up"] && !@sprites["up"].disposed?
    return unless @sprites["down"] && !@sprites["down"].disposed?

    if [2, 4, 14, 16].include?(@frame)
      @sprites["up"].y -= 1
      @sprites["down"].y -= 1
    elsif [6, 8, 10, 12].include?(@frame)
      @sprites["up"].y += 1
      @sprites["down"].y += 1
    end
  end

  def animate_character
    ["char", "char2"].each do |char_key|
      next unless @sprites[char_key]

      sprite = @sprites[char_key]
      sprite.src_rect.x += (sprite.bitmap.width / 4).round
      sprite.src_rect.x = 0 if sprite.src_rect.x >= sprite.bitmap.width
    end
  end

  ##---------------------------------------------------------------------------
  ##  Cleanup
  ##---------------------------------------------------------------------------

  def cleanup
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity -= FADE_SPEED if @sprites["bg0"] && i > 3

      @modes.size.times do |j|
        @sprites["btn#{j}"].opacity -= FADE_SPEED if @sprites["btn#{j}"]
      end

      @sprites["main"].opacity -= FADE_SPEED if @sprites["main"]
      @sprites["char"].opacity -= 40 if @sprites["char"]
      @sprites["char2"].opacity -= 40 if @sprites["char2"]
    end

    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbWait(1)
  end
end