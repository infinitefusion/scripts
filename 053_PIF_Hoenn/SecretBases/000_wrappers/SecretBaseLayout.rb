class SecretBaseLayout
  attr_accessor :items  #SecretBaseItemInstance
  attr_accessor :tileset #todo Reuse the same layouts map for all bases and change the tileset depending on the type
  attr_accessor :layout_template

  def initialize(layout_template)
    @layout_template = layout_template
    @items = []
  end

  def add_item(itemId, position = [0, 0])
    new_item = SecretBaseItemInstance.new(itemId, position)
    @items << new_item
    return new_item.instanceId
  end

  def get_item_at_position(position = [0,0])
    @items.each do |item|
      return item if item.position == position
    end
    return nil
  end

  def get_item_by_id(instanceId)
    @items.each do |item|
      return item if item.instanceId == instanceId
    end
    return nil
  end


  def remove_item_by_instance(instanceId)
    @items.each do |item|
      if item.instanceId == instanceId
        @items.delete(item)
      end
    end
    return nil
  end

  def remove_item_at_position(position = [0, 0])
    @items.each do |item|
      if item.position == position
        @items.delete(item)
      end
    end
  end

  # returns a list of ids of the items that are currently in the base's layout
  def list_items_instances()
    list = []
    @items.each do |item|
      list << item.instanceId
    end
  end
end