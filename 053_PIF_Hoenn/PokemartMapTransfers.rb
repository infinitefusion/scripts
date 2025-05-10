# frozen_string_literal: true

# Necessary dor setting the various events within the pokemart map, uses the numbers as wondertrade
def get_city_numerical_id(city_sym)
  current_city_numerical = {
    :LITTLEROOT => 1,
    :OLDALE => 2,
    :PETALBURG => 3,
    :RUSTBORO => 4,
    :DEWFORD => 5,
    :SLATEPORT => 6,
    :MAUVILLE => 7,
    :VERDANTURF => 8,
    :FALLARBOR => 9,
    :LAVARIDGE => 10,
    :FORTREE => 11,
    :LILYCOVE => 12,
    :MOSSDEEP => 13,
    :SOOTOPOLIS => 14,
    :PACIFIDLOG => 15,
    :EVERGRANDE => 16
  }
  return current_city_numerical[city_sym]
end

POKEMART_MAP_ID = 24
POKEMART_DOOR_POS = [12, 12]
# city -> Symbol
def enter_pokemart(city)
  pbSet(VAR_CURRENT_MART, city)
  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, get_city_numerical_id(city))
  echoln get_city_numerical_id(city)
  pbFadeOutIn {
    $game_temp.player_new_map_id = POKEMART_MAP_ID
    $game_temp.player_new_x = POKEMART_DOOR_POS[0]
    $game_temp.player_new_y = POKEMART_DOOR_POS[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end

def exit_pokemart()
  pokemart_entrances = {
    :LITTLEROOT => [1, 0, 0],
    :OLDALE => [1, 0, 0],
    :VERMILLION => [1, 0, 0],
    :PETALBURG => [7, 32, 19],
    :RUSTBORO => [1, 0, 0],
    :DEWFORD => [1, 0, 0],
    :SLATEPORT => [1, 0, 0],
    :MAUVILLE => [1, 0, 0],
    :VERDANTURF => [1, 0, 0],
    :FALLARBOR => [1, 0, 0],
    :LAVARIDGE => [1, 0, 0],
    :FORTREE => [1, 0, 0],
    :LILYCOVE => [1, 0, 0],
    :MOSSDEEP => [1, 0, 0],
    :SOOTOPOLIS => [1, 0, 0],
    :PACIFIDLOG => [1, 0, 0],
    :EVERGRANDE => [1, 0, 0],
  }
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PETALBURG if !current_city.is_a?(Symbol)

  entrance_map = pokemart_entrances[current_city][0]
  entrance_x = pokemart_entrances[current_city][1]
  entrance_y = pokemart_entrances[current_city][2]

  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, 0)
  pbSet(VAR_CURRENT_MART, 0)
  pbFadeOutIn {
    $game_temp.player_new_map_id = entrance_map
    $game_temp.player_new_x = entrance_x
    $game_temp.player_new_y = entrance_y
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end