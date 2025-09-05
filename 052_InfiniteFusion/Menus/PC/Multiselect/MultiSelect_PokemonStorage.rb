class PokemonStorage
  def pbDeleteMulti(box, indexes)
    for index in indexes
      self[box, index] = nil
    end
    self.party.compact! if box == -1
  end

  # Stores multiple Pokémon near a specific (x, y) position in a single box
  # Only commits the placement if all Pokémon can be placed
  # box_index: the box to store in
  # x, y: preferred coordinates in the box
  # pk_array: array of Pokémon to store
  def pbStoreCaughtBatch(pk_array, box_index = @currentBox, x = 0, y = 0)
    return -1 if pk_array.nil? || pk_array.empty?
    return -1 if self[box_index].is_a?(StorageTransferBox)

    box_width = PokemonBox::BOX_WIDTH
    box_height = PokemonBox::BOX_HEIGHT

    # Generate all coordinates in the box
    coords = []
    for yy in 0...box_height
      for xx in 0...box_width
        coords << [xx, yy]
      end
    end

    # Sort coordinates by Manhattan distance from (x, y)
    coords.sort_by! { |cx, cy| (cx - x).abs + (cy - y).abs }

    # Track which coordinates are available
    available_coords = coords.select do |cx, cy|
      index = cy * box_width + cx
      self[box_index, index].nil?
    end

    return -1 if available_coords.length < pk_array.length

    # Assign each Pokémon to the closest available slot
    assignments = []
    pk_array.each do |pkmn|
      slot = available_coords.shift
      assignments << slot
    end

    # Commit the placements
    assignments.each_with_index do |(cx, cy), i|
      index = cy * box_width + cx
      self[box_index, index] = pk_array[i][0]
    end

    @currentBox = box_index
    return box_index
  end




end
