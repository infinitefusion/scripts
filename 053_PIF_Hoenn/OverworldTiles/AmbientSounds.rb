Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]
  next unless event == $game_player
  max_volume = 25
  nearby_ambient_sounds = scan_for_ambient_sounds(5)
  if nearby_ambient_sounds.size > 0
    sound, distance = nearby_ambient_sounds.min_by { |_snd, dist| dist }
    volume = max_volume - (5 * distance)
    pbBGSPlay(sound, volume)
  else
    pbBGSFade(2)
  end
}


AMBIENT_SOUND_SCAN_RADIUS = 5
AMBIENT_SOUND_SCAN_OFFSETS = (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).flat_map { |dx|
  (-AMBIENT_SOUND_SCAN_RADIUS..AMBIENT_SOUND_SCAN_RADIUS).map { |dy| [dx, dy, dx.abs + dy.abs] }
}.select { |_dx, _dy, dist| dist <= AMBIENT_SOUND_SCAN_RADIUS }
                                                                                    .sort_by { |_dx, _dy, dist| dist }
                                                                                    .freeze

def scan_for_ambient_sounds(radius = AMBIENT_SOUND_SCAN_RADIUS)
  map = $MapFactory.getMapNoAdd($game_map.map_id)
  return {} if !map

  px = $game_player.x
  py = $game_player.y

  AMBIENT_SOUND_SCAN_OFFSETS.each do |dx, dy, distance|
    terrain_tag = map.terrain_tag(px + dx, py + dy, true)
    next unless terrain_tag && terrain_tag.ambient_sound
    return { terrain_tag.ambient_sound => distance } # sorted order => this is the closest
  end
  return {}
end

def calculate_distance_from_player(x, y)
  dx = (x - $game_player.x).abs
  dy = (y - $game_player.y).abs
  return dx + dy
end