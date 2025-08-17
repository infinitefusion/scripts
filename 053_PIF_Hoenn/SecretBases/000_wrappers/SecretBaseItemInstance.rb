# frozen_string_literal: true
class SecretBaseItemInstance
  attr_reader :itemId
  attr_reader :instanceId
  attr_accessor :position
  attr_accessor :itemTemplate

  RANDOM_ID_LENGTH = 6
  def initialize(itemId, position = [0,0])
    @instanceId = generate_new_instance_id(itemId)
    @itemId = itemId
    @position =position

    @itemTemplate = GameData::SECRET_BASE_ITEMS[@itemId]
  end

  def getGraphics()
    return @itemTemplate.graphics
  end
  def generate_new_instance_id(itemId)
    randomId = rand(36**RANDOM_ID_LENGTH).to_s(36)
    return "#{itemId}_#{randomId}"
  end


  def interact
    cmd_use = _INTL("Use")
    cmd_move = _INTL("Move")
    cmd_delete = _INTL("Put away")
    cmd_cancel = _INTL("Cancel")

    options = []
    options << cmd_use if @itemTemplate.behavior
    options << cmd_move
    options << cmd_delete if @itemTemplate.deletable
    options << cmd_cancel

    choice = optionsMenu(options)
    case options[choice]
    when cmd_use
      @itemTemplate.behavior.call
    when cmd_move
      moveSecretBaseItem(@instanceId,@position)
      return
    when cmd_delete

    end

  end
end