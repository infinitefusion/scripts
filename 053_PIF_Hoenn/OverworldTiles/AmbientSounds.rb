DEFAULT_AMBIENT_VOLUME = 25
AMBIENT_SOUND_SCAN_RADIUS = 5

Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]
  next unless event == $game_player
  nearby_ambient_sounds = scan_for_ambient_sounds(5)
  if nearby_ambient_sounds.size > 0
    sound, distance, max_volume = nearby_ambient_sounds.min_by { |_snd, dist, _vol| dist }
    volume = max_volume - (5 * distance)
    pbBGSPlay(sound, volume)
  else
    pbBGSFade(2)
  end
}

AMBIENT_SOUND_SCAN_OFFSETS = (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).flat_map { |dx|
  (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).map { |dy| [dx, dy, dx.abs + dy.abs] }
}.select { |_dx, _dy, dist| dist <= AMBIENT_SOUND_SCAN_RADIUS }
                                                                                    .sort_by { |_dx, _dy, dist| dist }
                                                                                    .freeze

def scan_for_ambient_sounds(radius = AMBIENT_SOUND_SCAN_RADIUS)
  map = $MapFactory.getMapNoAdd($game_map.map_id)
  return [] if !map

  px = $game_player.x
  py = $game_player.y

  AMBIENT_SOUND_SCAN_OFFSETS.each do |dx, dy, distance|
    terrain_tag = map.terrain_tag(px + dx, py + dy, true)
    next unless terrain_tag && terrain_tag.ambient_sound
    max_volume = terrain_tag.ambient_sound_max_volume || DEFAULT_AMBIENT_VOLUME
    return [[terrain_tag.ambient_sound, distance, max_volume]]
  end
  return []
end


def calculate_distance_from_player(x, y)
  dx = (x - $game_player.x).abs
  dy = (y - $game_player.y).abs
  return dx + dy
end