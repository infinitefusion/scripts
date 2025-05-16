class BetterRegionMap
  def update_weather_icon(location)
    return nil if !location
    map_id = location[4]
    return nil if !map_id

    weather_at_location = $game_weather.current_weather[map_id]
    return nil if weather_at_location.nil?

    weather_type = weather_at_location[0]
    weather_intensity = weather_at_location[1]

    icon = get_weather_icon(weather_type)
    return nil if icon.nil?
    icon_path = "Graphics/Pictures/Weather/Cursor/" + icon

    # @sprites["weather"].visible=true
    @sprites["cursor"].bmp(icon_path)
    @sprites["cursor"].src_rect.width = @sprites["cursor"].bmp.height
    return weather_type

  end
end
def get_current_map_weather_icon
  current_weather= $game_weather.current_weather[$game_map.map_id]
  weather_type = current_weather[0]
  icon = get_weather_icon(weather_type)
  return "Graphics/Pictures/Weather/" +icon if icon
  return nil
end
def get_weather_icon(weather_type)
  case weather_type
  when :Sunny #&& !PBDayNight.isNight?
    icon_path = "mapSun"
  when :Rain
    icon_path = "mapRain"
  when :Fog
    icon_path = "mapFog"
  when :StrongWinds
    icon_path = "mapWind"
  when :Storm
    icon_path = "mapStorm"
  when :Sandstorm
    icon_path = "mapSand"
  else
    icon_path = nil
  end
  return icon_path
end