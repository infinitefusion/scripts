# frozen_string_literal: true
class SecretBaseItemInstance
  attr_reader :itemId
  attr_reader :instanceId
  attr_accessor :position
  attr_accessor :direction

  attr_accessor :itemTemplate
  attr_accessor :event_id
  attr_reader :disposed
  RANDOM_ID_LENGTH = 6

  def initialize(itemId, position = [0, 0], direction= DIRECTION_DOWN)
    @itemId = itemId
    @instanceId = generate_new_instance_id()
    @direction = direction
    @position = position
  end

  def name
    return itemTemplate&.real_name
  end
  def getGraphics()
    return itemTemplate.graphics
  end

  def itemTemplate
    return SecretBasesData::SECRET_BASE_ITEMS[@itemId]
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

  def disposed?
    return @disposed
  end

  def dispose
    @itemId     = nil
    @position   = nil
    @direction  = nil
    @event_id   = nil
    @itemTemplate = nil
    @disposed = true
  end
end