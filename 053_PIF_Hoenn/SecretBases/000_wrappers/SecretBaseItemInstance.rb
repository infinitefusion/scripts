# frozen_string_literal: true
class SecretBaseItemInstance
  attr_reader :itemId
  attr_reader :instanceId
  attr_accessor :position
  attr_accessor :itemTemplate
  attr_accessor :event_id
  RANDOM_ID_LENGTH = 6

  def initialize(itemId, position = [0, 0])
    @itemId = itemId
    @instanceId = generate_new_instance_id()
    @position = position
    @itemTemplate = GameData::SECRET_BASE_ITEMS[@itemId]
  end

  def getGraphics()
    return @itemTemplate.graphics
  end

  def generate_new_instance_id()
    randomId = rand(36 ** RANDOM_ID_LENGTH).to_s(36)
    return "#{@itemId}_#{randomId}"
  end

  def setEventId(eventId)
    @event_id = eventId
  end

  def getEvent()
    return $game_map.events[@event_id]
  end

  def interact
    cmd_use = _INTL("Use")
    cmd_move = _INTL("Move")
    cmd_delete = _INTL("Put away")
    cmd_cancel = _INTL("Cancel")

    cmd_decorate = _INTL("Decorate!")
    cmd_storage = _INTL("Pokémon Storage")
    cmd_item_storage = _INTL("Item Storage")
    options = []
    if @itemId == :PC
      options << cmd_decorate
      options << cmd_storage
      options << cmd_item_storage
    else
      options << cmd_use if @itemTemplate.behavior
    end
    options << cmd_move
    options << cmd_delete if @itemTemplate.deletable
    options << cmd_cancel

    choice = optionsMenu(options)
    case options[choice]
    when cmd_use
      @itemTemplate.behavior.call
    when cmd_move
      moveSecretBaseItem(@instanceId, @position)
      return
    when cmd_delete

    when cmd_decorate
      decorateSecretBase
    when cmd_storage
      pbFadeOutIn {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(0) # Boot PC in organize mode
      }
    when cmd_item_storage
      pbPCItemStorage
    end

  end
end