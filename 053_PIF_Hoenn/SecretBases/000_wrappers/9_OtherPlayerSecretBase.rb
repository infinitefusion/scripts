class OtherPlayerSecretBase < SecretBase
  attr_reader :trainer_name, :trainer_badges, :trainer_game_mode
  attr_reader :trainer_appearance, :trainer_team

  def initialize(biome:, outside_map_id:, outside_entrance_position:, inside_map_id:, base_layout_type:, base_message:, trainer_data:)
    super(biome, outside_map_id, outside_entrance_position, inside_map_id, base_layout_type)

    @trainer_name       = trainer_data.name
    @trainer_badges     = trainer_data.nb_badges || 0
    @trainer_game_mode  = trainer_data.game_mode || 0
    @trainer_appearance = trainer_data.appearance
    @trainer_team       = trainer_data.team
    @base_message       = base_message
  end

end
