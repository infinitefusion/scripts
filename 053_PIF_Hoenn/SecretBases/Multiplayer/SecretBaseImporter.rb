class SecretBaseImporter
  def read_secret_base_json
    path = "Data/bases/secret_bases.json"
    return [] unless File.exist?(path)

    file_contents = File.read(path)
    begin
      # Parse with symbolized keys directly
      raw = JSON.parse(file_contents)
      return deep_clean(raw)   # cleaned object, keys stay symbols
    rescue Exception => e
      echoln caller
      echoln("SecretBaseImporter: Failed to parse JSON: #{e}")
      return []
    end
  end

  # Load all bases from the JSON
  def load_bases
    all_bases_data = read_secret_base_json
    return [] unless all_bases_data.is_a?(Array)

    # Only keep entries with a trainer
    visitor_bases = []
    all_bases_data.map do |entry|
      base_data    = entry[:base]
      trainer_data = entry[:trainer]

      base = VisitorSecretBase.new(
        biome: base_data[:biome],
        outside_map_id: base_data[:entrance_map],
        outside_entrance_position: base_data[:outside_entrance_position],
        inside_map_id: base_data[:inside_map_id],
        base_layout_type: base_data[:layout_type],
        trainer_data: import_trainer_from_json(trainer_data),
        base_message: base_data[:message],
      )
      visitor_bases << base
      base.dump_info
    end
    echoln visitor_bases
    return visitor_bases
  end

  def import_trainer_from_json(trainer_json)
    app = trainer_json[:appearance]
    trainer_appearance = TrainerAppearance.new(
      app[:skin_color], app[:hat], app[:clothes], app[:hair],
      app[:hair_color], app[:clothes_color], app[:hat_color],
      app[:hat2], app[:hat2_color]
    )

    team = trainer_json[:team].map do |poke_json|
      pokemon = Pokemon.new(poke_json[:species], poke_json[:level])
      pokemon.name     = poke_json[:name]
      pokemon.item     = poke_json[:item]
      pokemon.ability  = poke_json[:ability]
      pokemon.nature   = poke_json[:nature]
      pokemon.moves    = poke_json[:moves]

      if poke_json[:ivs]
        poke_json[:ivs].each do |stat, value|
          case stat.to_s.downcase
          when "hp"   then pokemon.iv[:HP] = value
          when "atk"  then pokemon.iv[:ATTACK] = value
          when "def"  then pokemon.iv[:DEFENSE] = value
          when "spe"  then pokemon.iv[:SPEED] = value
          when "spa"  then pokemon.iv[:SPECIAL_ATTACK] = value
          when "spd"  then pokemon.iv[:SPECIAL_DEFENSE] = value
          end
        end
      end

      if poke_json[:evs]
        poke_json[:evs].each do |stat, value|
          case stat.to_s.downcase
          when "hp"   then pokemon.ev[:HP] = value
          when "atk"  then pokemon.ev[:ATTACK] = value
          when "def"  then pokemon.ev[:DEFENSE] = value
          when "spe"  then pokemon.ev[:SPEED] = value
          when "spa"  then pokemon.ev[:SPECIAL_ATTACK] = value
          when "spd"  then pokemon.ev[:SPECIAL_DEFENSE] = value
          end
        end
      end

      pokemon.calc_stats
      pokemon
    end

    SecretBaseTrainer.new(
      trainer_json[:name],
      trainer_json[:nb_badges],
      trainer_json[:game_mode],
      trainer_appearance,
      team
    )
  end

  private

  # Recursively converts "" → nil, but keeps keys as symbols
  def deep_clean(obj)
    case obj
    when Hash
      obj.transform_values { |v| deep_clean(v) }
    when Array
      obj.map { |v| deep_clean(v) }
    when ""
      nil
    else
      obj
    end
  end
end
