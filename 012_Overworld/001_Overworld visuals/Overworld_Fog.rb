Events.onSpritesetCreate += proc { |_sender, e|
  spriteset = e[0]
  new_map_id = spriteset.map.map_id
  old_map_id = $Trainer.last_visited_map

  old_w = old_map_id ? $game_weather.get_map_weather_type(old_map_id) : :None
  new_w = $game_weather.get_map_weather_type(new_map_id)

  old_int = (old_w == :Fog) ? $game_weather.get_map_weather_intensity(old_map_id) : 0
  new_int = (new_w == :Fog) ? $game_weather.get_map_weather_intensity(new_map_id) : 0

  if old_int > 0 || new_int > 0
    spriteset.fade_in_fog(old_int, new_int)
  end
}

class Spriteset_Map
  alias fog_fade_init initialize
  def initialize(*args)
    @current_fog_opacity = 0 # Track locally to avoid connection stutter
    @fog_target_opacity = nil
    @fog_fade_speed = 0
    fog_fade_init(*args)
  end

  def fade_in_fog(old_intensity, new_intensity)
    @fog_target_opacity = (new_intensity * 20).clamp(0, 255)
    @current_fog_opacity = (old_intensity * 20).clamp(0, 255)

    @map.fog_name = "fog_tile" if @map.fog_name == "" && (new_intensity > 0 || old_intensity > 0)
    @fog_fade_speed = (@fog_target_opacity > @current_fog_opacity) ? 2 : -2
    @fog_target_opacity = nil if @current_fog_opacity == @fog_target_opacity
  end

  alias fog_fade_update update
  def update
    update_fog_fade
    fog_fade_update

    if @fog && (@fog_target_opacity != nil || @current_fog_opacity > 0)
      @fog.opacity = @current_fog_opacity
    end
  end

  def update_fog_fade
    return if @fog_target_opacity.nil?

    if @current_fog_opacity < @fog_target_opacity
      @current_fog_opacity = [@current_fog_opacity + @fog_fade_speed, @fog_target_opacity].min
    elsif @current_fog_opacity > @fog_target_opacity
      @current_fog_opacity = [@current_fog_opacity + @fog_fade_speed, @fog_target_opacity].max
    end

    if @current_fog_opacity == @fog_target_opacity
      if @current_fog_opacity == 0
        @map.fog_name = ""
      end
      @fog_target_opacity = nil
    end
  end
end