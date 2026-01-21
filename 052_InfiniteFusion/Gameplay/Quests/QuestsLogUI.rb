##=============================================================================
##  Easy Questing System - Refactored by Claude
##  Original by M3rein
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
##  Questlog - Main quest interface controller
##=============================================================================

class Questlog
  # Scene constants
  SCENE_MAIN = 0
  SCENE_LIST = 1
  SCENE_DETAIL = 2

  # Mode constants
  MODE_ONGOING = 0
  MODE_COMPLETED = 1

  # UI constants
  MAX_VISIBLE_QUESTS = 6
  FADE_SPEED = 32
  ANIMATION_FRAMES = 12
  CHAR_ANIMATION_INTERVAL = 6

  def initialize
    initialize_data
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
    @mode = MODE_ONGOING
    @box = 0          # Visible quest index (0-5)
    @frame = 0

    @completed = []
    @ongoing = []

    categorize_quests
  end

  def categorize_quests
    fix_broken_TR_quests

    $Trainer.quests.each do |quest|
      echoln "#{quest.id}: #{quest.completed}"

      if quest.completed
        @completed << quest unless @completed.include?(quest)
      else
        @ongoing << quest unless @ongoing.include?(quest)
      end
    end
  end

  def initialize_viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
  end

  def create_sprites
    create_main_bitmap
    create_background
    create_buttons
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

  def create_buttons
    2.times do |i|
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
    pbDrawOutlineText(@main, 0, 142, 512, 384,
                      _INTL("Ongoing: ") + @ongoing.size.to_s,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 198, 512, 384,
                      _INTL("Completed: ") + @completed.size.to_s,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
  end

  def animate_intro
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED if i < 8
      @sprites["btn0"].opacity += FADE_SPEED if i > 3
      @sprites["btn1"].opacity += FADE_SPEED if i > 3
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

      handle_input

      @frame = 0 if @frame == 18
    end
  end

  def handle_input
    case @scene
    when SCENE_MAIN
      handle_main_input
    when SCENE_LIST
      handle_list_input
    when SCENE_DETAIL
      handle_detail_input
    end
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
      show_quest_list(@main_menu_index)
    end

    animate_character if [6, 12, 18].include?(@frame)
  end

  ##---------------------------------------------------------------------------
  ##  Navigation
  ##---------------------------------------------------------------------------

  def switch_button(dir)
    if dir == :DOWN
      return if @main_menu_index == 1
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
    quest_list = @mode == MODE_ONGOING ? @ongoing : @completed
    return if quest_list.empty?

    if dir == :DOWN
      return if @quest_list_menu_index == quest_list.size - 1

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
    sprite_key = @mode == MODE_ONGOING ? "ongoing#{@box}" : "completed#{@box}"
    @sprites[sprite_key].src_rect.y = 0 if @sprites[sprite_key]
  end

  def select_current_quest
    sprite_key = @mode == MODE_ONGOING ? "ongoing#{@box}" : "completed#{@box}"
    if @sprites[sprite_key]
      @sprites[sprite_key].src_rect.y = (@sprites[sprite_key].bitmap.height / 2).round
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
    @ongoing.size.times do |i|
      break if i > 5
      @sprites["ongoing#{i}"].opacity -= FADE_SPEED if @sprites["ongoing#{i}"]
    end

    @completed.size.times do |i|
      break if i > 5
      @sprites["completed#{i}"].opacity -= FADE_SPEED if @sprites["completed#{i}"]
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
    pbDrawOutlineText(@main, 0, 142, 512, 384,
                      _INTL("Ongoing: ") + @ongoing.size.to_s,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
    pbDrawOutlineText(@main, 0, 198, 512, 384,
                      _INTL("Completed: ") + @completed.size.to_s,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
  end

  def animate_main_return
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["bg0"].opacity += FADE_SPEED if i < 8
      @sprites["btn0"].opacity += FADE_SPEED if i > 3
      @sprites["btn1"].opacity += FADE_SPEED if i > 3
      @sprites["main"].opacity += 48 if i > 5
    end
  end

  ##---------------------------------------------------------------------------
  ##  Quest List Display
  ##---------------------------------------------------------------------------

  def show_quest_list(mode)
    pbWait(2)
    @page = 0
    @scene = SCENE_LIST
    @mode = mode
    @box = 0

    @box = [@quest_list_menu_index, MAX_VISIBLE_QUESTS-1].min
    create_arrow_sprites
    fade_to_list
    clear_bitmaps

    if mode == MODE_ONGOING
      display_ongoing_quests
    else
      display_completed_quests
    end
  end

  def create_arrow_sprites
    @sprites["up"] = create_arrow(36, false)
    @sprites["down"] = create_arrow(360, true)
    @sprites["down"].visible = (@mode == MODE_ONGOING ? @ongoing.size : @completed.size) > MAX_VISIBLE_QUESTS
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
        @sprites["btn0"].opacity -= FADE_SPEED
        @sprites["btn1"].opacity -= FADE_SPEED
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

  def display_ongoing_quests
    display_quest_list(@ongoing, "ongoing", _INTL("Ongoing Quests"), _INTL("No ongoing quests"))
  end

  def display_completed_quests
    display_quest_list(@completed, "completed", _INTL("Completed Quests"), _INTL("No completed quests"))
  end

  def display_quest_list(quests, prefix, title, empty_msg)
    [quests.size, MAX_VISIBLE_QUESTS].min.times do |i|
      create_quest_sprite(i, quests[i], prefix)
      draw_quest_name(i, quests[i])
    end

    if quests.empty?
      pbDrawOutlineText(@main, 0, 175, 512, 384, empty_msg,
                        pbColor(:WHITE), pbColor(:BLACK), 1)
    end

    pbDrawOutlineText(@main, 0, 2, 512, 384, title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)

    animate_quest_list(quests.size)
  end

  def create_quest_sprite(index, quest, prefix)
    sprite_key = "#{prefix}#{index}"
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

  def animate_quest_list(quest_count)
    ANIMATION_FRAMES.times do |i|
      Graphics.update
      @sprites["main"].opacity += FADE_SPEED if i < 8
      @sprites["down"].opacity += FADE_SPEED if i > 3

      [quest_count, MAX_VISIBLE_QUESTS].min.times do |j|
        sprite_key = @mode == MODE_ONGOING ? "ongoing#{j}" : "completed#{j}"
        @sprites[sprite_key].opacity += FADE_SPEED if i > 3
      end
    end
  end

  def refresh_quest_list
    @main.clear if @main

    quest_list = @mode == MODE_ONGOING ? @ongoing : @completed
    sprite_prefix = @mode == MODE_ONGOING ? "ongoing" : "completed"

    # Determine which quest should appear in each visible slot
    MAX_VISIBLE_QUESTS.times do |i|
      next if i >= quest_list.size

      # Calculate which quest should appear in this slot
      quest_index = @quest_list_menu_index - @box + i
      quest_index = 0 if quest_index < 0
      quest_index = quest_list.size - 1 if quest_index >= quest_list.size

      # Assign quest to sprite and draw its name
      @sprites["#{sprite_prefix}#{i}"].quest = quest_list[quest_index]
      draw_quest_name(i, quest_list[quest_index])
    end

    # Update arrow visibility
    @sprites["up"].visible = @quest_list_menu_index > 0
    @sprites["down"].visible = @quest_list_menu_index < quest_list.size - 1

    # Redraw the title
    title = @mode == MODE_ONGOING ? _INTL("Ongoing Quests") : _INTL("Completed Quests")
    pbDrawOutlineText(@main, 0, 2, 512, 384, title,
                      Color.new(255, 255, 255), Color.new(0, 0, 0), 1)
  end


  def calculate_quest_offset(index)
    case index
    when 0 then -5
    when 1 then -4
    when 2 then -3
    when 3 then -2
    when 4 then -1
    else 0
    end
  end

  def update_arrow_visibility(quest_list, sprite_prefix)
    @sprites["up"].visible = @sprites["#{sprite_prefix}0"].quest != quest_list[0]
    @sprites["down"].visible = @sprites["#{sprite_prefix}5"].quest != quest_list[quest_list.size - 1]
  end

  ##---------------------------------------------------------------------------
  ##  Quest Detail Display
  ##---------------------------------------------------------------------------

  def show_quest_detail
    quest_list = @mode == MODE_ONGOING ? @ongoing : @completed
    return if quest_list.empty?

    quest = quest_list[@quest_list_menu_index]
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
      @sprites["ongoing#{i}"].opacity -= FADE_SPEED if @sprites["ongoing#{i}"]
      @sprites["completed#{i}"].opacity -= FADE_SPEED if @sprites["completed#{i}"]
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
      @sprites["btn0"].opacity -= FADE_SPEED if @sprites["btn0"]
      @sprites["btn1"].opacity -= FADE_SPEED if @sprites["btn1"]
      @sprites["main"].opacity -= FADE_SPEED if @sprites["main"]
      @sprites["char"].opacity -= 40 if @sprites["char"]
      @sprites["char2"].opacity -= 40 if @sprites["char2"]
    end

    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbWait(1)
  end
end