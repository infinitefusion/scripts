class Game_Event
  def player_near_event?(radius)
    dx = $game_player.x - @x
    dy = $game_player.y - @y
    distance = Math.sqrt(dx * dx + dy * dy)
    return distance <= radius
  end

  def playerNextToEvent?
    return player_near_event?(1)
  end
end


def trigger_overworld_wild_battle
  return if $PokemonTemp.overworld_wild_battle_triggered
  $PokemonTemp.overworld_wild_battle_triggered = true
  case $PokemonTemp.overworld_wild_battle_participants.length
  when 0
    $PokemonTemp.overworld_wild_battle_triggered = false
    return
  when 2
    battler1 = $PokemonTemp.overworld_wild_battle_participants[0]
    battler2 = $PokemonTemp.overworld_wild_battle_participants[1]
    pb1v2WildBattleSpecific(battler1, battler2)
    $PokemonTemp.overworld_wild_battle_participants = []
  when 3
    battler1 = $PokemonTemp.overworld_wild_battle_participants[0]
    battler2 = $PokemonTemp.overworld_wild_battle_participants[1]
    battler3 = $PokemonTemp.overworld_wild_battle_participants[2]
    pb1v2WildBattleSpecific(battler1, battler2, battler3)
    $PokemonTemp.overworld_wild_battle_participants = []
  else
    battler = $PokemonTemp.overworld_wild_battle_participants[0]
    pbWildBattleSpecific(battler)
    $PokemonTemp.overworld_wild_battle_participants.shift
  end
  $PokemonTemp.overworld_wild_battle_triggered = false
end


def setupAsOverworldPokemon(species: ,level: , behavior_roaming:nil, behavior_notice:nil )
  return #todo: fixme - also spawns events in connecting maps...

  event = $game_map.events[@event_id]
  x, y = event.x, event.y
  terrain = $game_map.terrain_tag(x, y)
  pokemon = [species, level]
  event.erase
  ow_event = spawn_overworld_pokemon(pokemon,[x,y],terrain,behavior_roaming,behavior_notice)
  if ow_event
     ow_event.behavior_roaming = behavior_roaming if behavior_roaming
     ow_event.behavior_notice = behavior_notice if behavior_notice
  end
end

# Called from automatically spawned overworld Pokemon - species and level is obtained from name
def overworldPokemonBehavior()
  event = $MapFactory.getMap(@map_id).events[@event_id]
  return unless event && event.is_a?(OverworldPokemonEvent)
  begin
    event.update_behavior
  rescue
    return
  end
end



