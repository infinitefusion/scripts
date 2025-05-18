# frozen_string_literal: true


def isRaining?()
  return isWeatherRain? || isWeatherStorm?
end

def isWeatherRain?()
  return $game_weather.get_map_weather_type($game_map.map_id) == :Rain || $game_weather.get_map_weather_type($game_map.map_id) == :HeavyRain
end

def isWeatherSunny?()
  return $game_weather.get_map_weather_type($game_map.map_id) == :Sunny || $game_weather.get_map_weather_type($game_map.map_id) == :HarshSun
end

def isWeatherStorm?()
  return $game_weather.get_map_weather_type($game_map.map_id) == :Storm
end

def isWeatherWind?()
  return $game_weather.get_map_weather_type($game_map.map_id) == :Wind || $game_weather.get_map_weather_type($game_map.map_id) == :StrongWinds
end

def isWeatherFog?()
  return $game_weather.get_map_weather_type($game_map.map_id) == :Fog
end