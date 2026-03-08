
class ContactsAppInfoPageScene < PokeNavAppScene
  INFO_TEXT_Y = 270

  def header_name
    return _INTL("Trainers")
  end

  def cursor_path
    return "Graphics/Pictures/Pokeradar/icon_button"
  end

  def header_path
    return "Graphics/Pictures/Pokeradar/bg_header"
  end

  def display_mode
    return :LIST
  end

  def x_gap
    return 75;
  end

  def y_gap
    return 50;
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

  def pbStartScene(screen, trainer_id)
    @trainer = getRebattledTrainerFromKey(trainer_id)
    super(screen, [])
    showTrainerInfo
  end

  def showTrainerInfo
    Kernel.pbClearText
    showHeaderName

    trainerClassName = GameData::TrainerType.get(@trainer.trainerType).real_name
    trainer_name = "#{trainerClassName} #{@trainer.trainerName}"

    Kernel.pbDisplayText(trainer_name, Graphics.width / 2, 30, 999999, @text_color_base, @text_color_shadow)
  end


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
      @screen.view_trainer_team(@trainer.id)
    end
  end

  def hover(button_id)
    super
  end
end
