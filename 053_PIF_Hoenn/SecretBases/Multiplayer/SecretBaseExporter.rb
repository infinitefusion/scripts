class SecretBaseExporter
  # Export a secret base as JSON
  def export_secret_base(secretBase)
    base_data = {
      base: {
        biome: secretBase.biome_type || "",
        entrance_map: secretBase.outside_map_id || 0,
        entrance_position: secretBase.outside_entrance_position || [0, 0],
        layout_type: secretBase.base_layout_type || "",
        layout: {
          items: list_base_items(secretBase)
        }
      },
      trainer: {
        name: $Trainer.name || "",
        nb_badges: $Trainer.badge_count || 0,
        game_mode: $Trainer.game_mode || 0,
        appearance: sanitize_string(export_current_outfit_to_json),
        team: export_team_as_array
      }
    }

    JSON.generate(sanitize_string(base_data))
  end

  # Export all items in the base layout
  def list_base_items(secretBase)
    return [] unless secretBase&.layout&.items
    secretBase.layout.items.map do |item|
      {
        id: item.itemId || "",
        position: item.position || [0, 0]
      }
    end
  end

  # Export the trainer's Pokémon party
  def export_team_as_array
    $Trainer.party.compact.map { |p| export_fused_pokemon_hash(p) }
  end

  # Export a single Pokémon as a hash
  def export_fused_pokemon_hash(pokemon)
    {
      species: pokemon.species.to_s,
      name:    pokemon.name || "",
      item:    pokemon.item ? pokemon.item.id.to_s : "",
      ability: pokemon.ability ? pokemon.ability.id.to_s : "",
      level:   pokemon.level || 1,
      evs: {
        hp:  pokemon.ev[:HP] || 0,
        atk: pokemon.ev[:ATTACK] || 0,
        def: pokemon.ev[:DEFENSE] || 0,
        spa: pokemon.ev[:SPECIAL_ATTACK] || 0,
        spd: pokemon.ev[:SPECIAL_DEFENSE] || 0,
        spe: pokemon.ev[:SPEED] || 0
      },
      ivs: {
        hp:  pokemon.iv[:HP] || 0,
        atk: pokemon.iv[:ATTACK] || 0,
        def: pokemon.iv[:DEFENSE] || 0,
        spa: pokemon.iv[:SPECIAL_ATTACK] || 0,
        spd: pokemon.iv[:SPECIAL_DEFENSE] || 0,
        spe: pokemon.iv[:SPEED] || 0
      },
      nature: GameData::Nature.get(pokemon.nature).id.to_s,
      moves:  pokemon.moves.compact.map { |m| GameData::Move.get(m.id).id.to_s }
    }
  end

  private

  # Recursively replace nils with empty strings (or zero if numeric leaf)
  def sanitize_string(obj)
    case obj
    when Hash
      obj.transform_values { |v| sanitize_string(v) }
    when Array
      obj.map { |v| sanitize_string(v) }
    when NilClass
      ""
    else
      obj
    end
  end
end
