class Game_Map
  SECRET_BASE_TILESET_OVERRIDES = {
    :TREE => 100,
    :CAVE => 101
  }

  alias __tileset_swap_updateTileset updateTileset

  def updateTileset
    if @map_id == MAP_SECRET_BASES && $Trainer.secretBase
      override = SECRET_BASE_TILESET_OVERRIDES[$Trainer.secretBase.biome_type]
      @map.tileset_id = override if override
    end
    __tileset_swap_updateTileset
  end
end


