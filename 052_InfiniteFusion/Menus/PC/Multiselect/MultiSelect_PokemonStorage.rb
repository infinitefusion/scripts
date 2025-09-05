class PokemonStorage
  def pbDeleteMulti(box, indexes)
    for index in indexes
      self[box, index] = nil
    end
    self.party.compact! if box == -1
  end
end
