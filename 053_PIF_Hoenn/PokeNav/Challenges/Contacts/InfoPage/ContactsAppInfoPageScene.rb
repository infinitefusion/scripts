class ContactsAppInfoPageScene < PokeNavAppScene
  SPRITE_POSITION_X = 400
  SPRITE_POSITION_Y = 230

  TITLE_TEXT_X = 370
  TITLE_TEXT_Y = 50

  INFO_HEADER_X = 40
  INFO_TEXT_X = 60
  INFO_TEXT_START_Y = 50
  INFO_TEXT_GAP = 40
  INFO_HEADER_GAP = 30

  def header_name
    return _INTL("Trainers")
  end

  def cursor_path
    return "Graphics/Pictures/Pokeradar/icon_button"
  end

  def header_path
    return "Graphics/Pictures/Pokegear/bg_header_trainers"
  end

  def bg_path
    return "Graphics/Pictures/Pokegear/Trainers/bg_summary"
  end

  def display_mode
    return :LIST
  end

  def x_gap
    return 75;
  end

  def y_gap
    return 64;
  end

  def columns
    return 1
  end

  def visible_rows
    return 3
  end

  def start_x
    return 40;
  end

  def start_y
    return 80;
  end

  def initialize
    super
    @value_color_base = Color.new(24, 112, 216)
    @value_color_shadow = Color.new(136, 168, 208)
    if isDarkMode
      @value_color_base, @value_color_shadow = @value_color_shadow, @value_color_base
    end

  end

  def pbStartScene(screen, trainer)
    @screen = screen
    buttons = []
    @trainer = trainer
    super(buttons)
    if @trainer
      showTrainerSprite
      showTrainerInfo
    else
      pbEndScene
    end

  end

  def showTrainerSprite
    if @trainer.id == BATTLED_TRAINER_RIVAL_KEY
      bitmap = generate_front_trainer_sprite_bitmap_from_appearance($Trainer.rival_appearance).bitmap
      @sprites["trainer"] = IconSprite.new(0, 0, @viewport)
      @sprites["trainer"].setBitmapDirectly(bitmap)
    else
      trainerFile = GameData::TrainerType.front_sprite_filename(@trainer.trainerType)
      @sprites["trainer"] = IconSprite.new(0, 0, @viewport)
      @sprites["trainer"].setBitmap(trainerFile)
    end

    if @sprites["trainer"].bitmap &&
      @sprites["trainer"].bitmap.width > @sprites["trainer"].bitmap.height * 2
      @sprites["trainer"].src_rect.x = 0
      @sprites["trainer"].src_rect.width = @sprites["trainer"].bitmap.width / 5
    end

    @sprites["trainer"].ox = @sprites["trainer"].src_rect.width / 2
    @sprites["trainer"].oy = @sprites["trainer"].bitmap.height
    @sprites["trainer"].z = 50
    @sprites["trainer"].x = SPRITE_POSITION_X
    @sprites["trainer"].y = SPRITE_POSITION_Y

  end

  def showTrainerInfo
    echoln "show trainer info"
    Kernel.pbClearText
    showHeaderName

    trainerClassName = GameData::TrainerType.get(@trainer.trainerType).real_name
    trainer_name = "#{trainerClassName} #{@trainer.trainerName}"

    level_sum = 0
    @trainer.currentTeam.each do |pokemon|
      level_sum += pokemon.level
    end
    average_level = (level_sum / @trainer.currentTeam.length).round

    Kernel.pbDisplayText(trainer_name, TITLE_TEXT_X, TITLE_TEXT_Y, 999999, @text_color_base, @text_color_shadow)

    current_y = INFO_TEXT_START_Y
    displayText(_INTL("Location:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(_INTL(@trainer.location), INFO_TEXT_X, current_y)

    current_y += INFO_TEXT_GAP
    displayText(_INTL("Average team level:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(average_level.to_s, INFO_TEXT_X, current_y)

    current_y += INFO_TEXT_GAP
    displayText(_INTL("Favorite type:"), INFO_HEADER_X, current_y)
    current_y += INFO_HEADER_GAP
    displayValue(GameData::Type.get(@trainer.favorite_type).real_name, INFO_TEXT_X, current_y)

    if @trainer.previous_random_events
      trainer_data = GameData::Trainer.try_get(@trainer.trainerType, @trainer.trainerName, 0)
      action = getBestMatchingPreviousRandomEvent(trainer_data, @trainer.previous_random_events)
      if action
        case action.eventType
        when :CATCH
          action_text = _INTL("Recently caught a {1}",
                              GameData::Species.get(action.caught_pokemon).real_name)
        when :EVOLVE
          action_text = _INTL("Recently evolved their {1}",
                              GameData::Species.get(action.evolved_pokemon).real_name)
        when :FUSE
          action_text = _INTL("Recently fused their {1} and {2}",
                              GameData::Species.get(action.fusion_head_pokemon).real_name,
                              GameData::Species.get(action.fusion_body_pokemon).real_name)
        when :UNFUSE
          action_text = _INTL("Recently unfused their {1}",
                              GameData::Species.get(action.unfused_pokemon).real_name)
        when :REVERSE
          action_text = _INTL("Recently reversed their {1}",
                              GameData::Species.get(action.reversed_pokemon).real_name)
        end
        current_y += INFO_TEXT_GAP*1.5
        displayText(action_text, INFO_HEADER_X, current_y)
      end
    end
  end

  def displayText(text, x_position, y_position)
    Kernel.pbDisplayText(text, x_position, y_position, nil, @text_color_base, @text_color_shadow, 3)
  end

  def displayValue(text, x_position, y_position)
    Kernel.pbDisplayText(text, x_position, y_position, nil, @value_color_base, @value_color_shadow, 3)
  end

  # def Kernel.pbDisplayText(message,xposition,yposition,z=nil, baseColor=nil, shadowColor=nil,alignment=2)

  def createCursor
    return if $PokemonTemp.pokeradar
    super
  end

  def click(button_id)
    super
    cmd_team = _INTL("View Team")
    cmd_cancel = _INTL("Cancel")
    commands = [cmd_team, cmd_cancel]
    choice = pbMessage(_INTL("What would you like to do?"), commands, commands.size)
    case commands[choice]
    when cmd_team
      Kernel.pbClearText()
      @screen.view_trainer_team(@trainer.id)
      showTrainerInfo
    end
  end

  def hover(button_id)
    super
  end
end
