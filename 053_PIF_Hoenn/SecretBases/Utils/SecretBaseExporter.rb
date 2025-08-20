def export_secret_base(secretBase)
  base_data = {
    base: {
      biome:            secretBase.biome_type,
      entrance_map:     secretBase.outside_map_id,
      entrance_position: secretBase.outside_entrance_position,
      layout_type:      secretBase.base_layout_type,
      layout: {
        items: list_base_items(secretBase)
      }
    },
    trainer: {
      name:  $Trainer.name,
      nb_badges: $Trainer.badge_count,
      game_mode: $Trainer.game_mode,
      appearance: export_current_outfit_to_json,
      team:  export_team_as_array
    }
  }
  JSON.generate(base_data)
end

def list_base_items(secretBase)
  return [] unless secretBase&.layout&.items
  secretBase.layout.items.map { |item|
    { id: item.itemId, position: item.position }
  }
end



def load_available_secret_bases(json_str)
  all_bases = parse_json(json_str)
  return [] unless all_bases.is_a?(Array)

  # Filter eligible bases
  eligible = all_bases.select do |base|
    base["trainer"] && base["trainer"]["nb_badges"].to_i <= $Trainer.nb_badges
  end

  # Split into equal and lower badge groups
  equal_badges = eligible.select { |b| b["trainer"]["nb_badges"].to_i == $Trainer.nb_badges }
  lower_badges = eligible.select { |b| b["trainer"]["nb_badges"].to_i < $Trainer.nb_badges }

  # Prioritize equal badges, then fill with lowers if needed
  chosen = []
  chosen.concat(equal_badges.sample([equal_badges.size, 5].min)) # grab from equals first
  if chosen.size < 5
    needed = 5 - chosen.size
    chosen.concat(lower_badges.sample([lower_badges.size, needed].min))
  end

  # Instantiate SecretBase objects
  chosen.map do |base|
    OtherPlayerSecretBase.new(
      id: base["id"],
      trainer: Trainer.new(
        name: base["trainer"]["name"],
        nb_badges: base["trainer"]["nb_badges"].to_i
      ),
      layout: base["layout"]
    )
  end
end

