class PokemonStorage
  def pbDeleteMulti(box, indexes)
    for index in indexes
      self[box, index] = nil
    end
    self.party.compact! if box == -1
  end

  # Stores multiple Pokémon near a specific (x, y) position in a single box.
  # Only commits the placement if all Pokémon can be placed.
  # box_index: the box to store in
  # x, y: cursor coordinates in the box
  # pokemon_positions_array: array of Pokémon to store
  #
  # Returns a status:
  # :CANT_PLACE : There's no room in the box to place Pokemon, no changes were made
  # :PLACED_ALL_FREE : All the spots were free, everything placed where it was supposed
  # :PLACED_OCCUPIED : Placed, but had to move some Pokemon
  def pbStoreBatch(pokemon_positions_array, box_index = @currentBox, cursor_x = 0, cursor_y = 0)
    return -1 if pokemon_positions_array.nil? || pokemon_positions_array.empty?
    return -1 if self[box_index].is_a?(StorageTransferBox)
    box_width  = PokemonBox::BOX_WIDTH
    box_height = PokemonBox::BOX_HEIGHT

    # List all coordinates in the box
    coords = []
    for yy in 0...box_height
      for xx in 0...box_width
        coords << [xx, yy]
      end
    end

    # -----------------------------
    # Phase 1: Assign guaranteed spots
    # -----------------------------
    assignments = Array.new(pokemon_positions_array.length)
    unplaced    = []   # indices of Pokémon that still need a slot
    intended    = []   # store intended positions even if blocked

    pokemon_positions_array.each_with_index do |pokemon_data_array, i|
      relative_position = [pokemon_data_array[1], pokemon_data_array[2]]
      intended_position = [cursor_x + relative_position[0], cursor_y + relative_position[1]]

      # Check bounds
      if intended_position[0] >= box_width || intended_position[1] >= box_height
        intended[i] = nil
        unplaced << i
        next
      end

      intended[i] = intended_position
      index = intended_position[1] * box_width + intended_position[0]

      if self[box_index, index].nil?
        assignments[i] = intended_position   # Free slot, lock it in
      else
        unplaced << i                         # Occupied, resolve later
      end
    end

    # -----------------------------
    # Phase 2: Assign leftovers by intended position
    # -----------------------------
    used_coords = assignments.compact
    available_coords = coords.reject do |cx, cy|
      index = cy * box_width + cx
      !self[box_index, index].nil? || used_coords.include?([cx, cy])
    end

    if available_coords.length < unplaced.length  || available_coords.length < intended.length
      return :CANT_PLACE # Not enough room
    end

    unplaced.each do |i|
      target = intended[i] || [cursor_x, cursor_y] # fallback to cursor if no intended
      available_coords.sort_by! { |cx, cy| (cx - target[0]).abs + (cy - target[1]).abs }
      assignments[i] = available_coords.shift
    end

    # -----------------------------
    # Commit placements
    # -----------------------------
    assignments.each_with_index do |(cx, cy), i|
      index = cy * box_width + cx
      self[box_index, index] = pokemon_positions_array[i][0]
    end

    # Status return
    if unplaced.empty?
      return :PLACED_ALL_FREE
    else
      return :PLACED_OCCUPIED
    end
  end


end
