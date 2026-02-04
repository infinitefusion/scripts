# All weather particles are assumed to start at the top/right and move to the
# bottom/left. Particles are only reset if they are off-screen to the left or
# bottom.
module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy
    MAX_SPRITES              = 60
    FADE_OLD_TILES_START     = 0
    FADE_OLD_TILES_END       = 1
    FADE_OLD_TONE_START      = 0
    FADE_OLD_TONE_END        = 2
    FADE_OLD_PARTICLES_START = 1
    FADE_OLD_PARTICLES_END   = 3
    FADE_NEW_PARTICLES_START = 2
    FADE_NEW_PARTICLES_END   = 4
    FADE_NEW_TONE_START      = 3
    FADE_NEW_TONE_END        = 5
    FADE_NEW_TILES_START     = 4
    FADE_NEW_TILES_END       = 5

    FADE_FOG_OPACITY_START      = 0
    FADE_FOG_OPACITY_END        = 8.0

    def initialize(viewport = nil)
      @viewport         = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z       = viewport.z + 1
      @origViewport     = viewport
      @weatherTypes = {}
      @type                 = :None
      @max                  = 0
      @ox                   = 0
      @oy                   = 0
      @tiles_wide           = 0
      @tiles_tall           = 0
      @tile_x               = 0.0
      @tile_y               = 0.0
      @sun_magnitude        = 0
      @sun_strength         = 0
      @time_until_flash     = 0
      @sprites              = []
      @sprite_lifetimes     = []
      @tiles                = []
      @new_sprites          = []
      @new_sprite_lifetimes = []
      @fading               = false

      @lightning_overlay = Sprite.new(@viewport)
      @lightning_overlay.bitmap = RPG::Cache.load_bitmap("Graphics/Weather/", "lightning") if pbResolveBitmap("Graphics/Weather/lightning")
      @lightning_overlay.opacity = 0
      @lightning_overlay.z = 2000

      @old_fog_opacity = 0
      @target_fog_opacity = 0
      @start_opacity = 0 # NEW
      @end_opacity = 0   # NEW
    end

    def dispose
      @sprites.each { |sprite| sprite.dispose if sprite }
      @new_sprites.each { |sprite| sprite.dispose if sprite }
      @tiles.each { |sprite| sprite.dispose if sprite }
      @viewport.dispose
      @weatherTypes.each_value do |weather|
        next if !weather
        weather[1].each { |bitmap| bitmap.dispose if bitmap }
        weather[2].each { |bitmap| bitmap.dispose if bitmap }
      end
      @lightning_sprite.dispose if @lightning_sprite
    end

    def get_max_sprites(power, weather_type)
      power= MAX_SPRITES if !power
      if weather_type == :Wind
        power /= 8
      end
      return (power + 1) * RPG::Weather::MAX_SPRITES / 10
    end

    def fade_in(new_type, weather_power, duration = 1)
      return if @fading
      @start_opacity = $game_map.fog_opacity
      new_max = get_max_sprites(weather_power, new_type)
      new_id = GameData::Weather.get(new_type).id

      if new_id == :None
        @end_opacity = 0
      else
        @end_opacity = 16 * new_max
      end

      return if @type == new_id && @max == new_max

      if duration > 0
        @target_type = new_id
        @target_max = new_max
        prepare_bitmaps(@target_type)
        @old_max = @max
        @new_max = 0
        @old_tone = Tone.new(@viewport.tone.red, @viewport.tone.green,
                             @viewport.tone.blue, @viewport.tone.gray)
        @target_tone = get_weather_tone(@target_type, @target_max)
        @fade_time = 0.0
        @time_shift = 0
        if @type == :None
          @time_shift += 2
        elsif !GameData::Weather.get(@type).has_tiles?
          @time_shift += 1
        end
        @fading = true
        @new_sprites.each { |sprite| sprite.dispose if sprite }
        @new_sprites.clear
        ensureSprites
        @new_sprites.each_with_index { |sprite, i| set_sprite_bitmap(sprite, i, @target_type) }
      else
        self.type = new_id
        self.set_max(new_max, new_id)
      end
    end

    def type=(type)
      type = GameData::Weather.get(type).id
      return if @type == type
      if @fading
        @max = @target_max
        @fading = false
      end
      @type = type
      set_fog(type)
      prepare_bitmaps(@type)
      if GameData::Weather.get(@type).has_tiles?
        w = @weatherTypes[@type][2][0].width
        h = @weatherTypes[@type][2][0].height
        @tiles_wide = (Graphics.width.to_f / w).ceil + 1
        @tiles_tall = (Graphics.height.to_f / h).ceil + 1
      else
        @tiles_wide = @tiles_tall = 0
      end
      ensureSprites
      @sprites.each_with_index { |sprite, i| set_sprite_bitmap(sprite, i, @type) }
      ensureTiles
      @tiles.each_with_index { |sprite, i| set_tile_bitmap(sprite, i, @type) }
    end

    def set_fog(weather_type)
      weather = GameData::Weather.get(weather_type)
      # Reset ALL maps first
      $MapFactory.maps.each do |m|
        m.fog_name = nil
        m.fog_opacity = 0
      end

      # Apply ONLY to current map
      map = $game_map
      if !weather.nil? && !weather.fog_name.nil?
        map.fog_name    = weather.fog_name
        current_p       = (@fading) ? @target_max : @max
        map.fog_opacity = (16 * current_p).to_i
        map.fog_sx      = weather.tile_delta_x
        map.fog_sy      = weather.tile_delta_y
      end
    end

    def set_max(value,weather_type)
      return if @max == value
      return if get_max_sprites(value,weather_type) <= 0
      value = value.clamp(0, get_max_sprites(value,weather_type))
      @max = value
      ensureSprites
      for i in 0...MAX_SPRITES
        @sprites[i].visible = (i < @max) if @sprites[i]
      end
    end

    def ox=(value)
      return if value == @ox
      @ox = value
      @sprites.each { |sprite| sprite.ox = @ox if sprite }
      @new_sprites.each { |sprite| sprite.ox = @ox if sprite }
      @tiles.each { |sprite| sprite.ox = @ox if sprite }
    end

    def oy=(value)
      return if value == @oy
      @oy = value
      @sprites.each { |sprite| sprite.oy = @oy if sprite }
      @new_sprites.each { |sprite| sprite.oy = @oy if sprite }
      @tiles.each { |sprite| sprite.oy = @oy if sprite }
    end

    def get_weather_tone(weather_type, maximum)
      return GameData::Weather.get(weather_type).tone(maximum)
    end

    def prepare_bitmaps(new_type)
      weather_data = GameData::Weather.get(new_type)
      bitmap_names = weather_data.graphics
      @weatherTypes[new_type] = [weather_data, [], []]
      for i in 0...2
        next if !bitmap_names[i]
        bitmap_names[i].each do |name|
          bitmap = RPG::Cache.load_bitmap("Graphics/Weather/", name)
          @weatherTypes[new_type][i + 1].push(bitmap)
        end
      end
    end

    def ensureSprites
      if @sprites.length < MAX_SPRITES && @weatherTypes[@type] && @weatherTypes[@type][1].length > 0
        for i in 0...MAX_SPRITES
          if !@sprites[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @sprites[i] = sprite
          end
          @sprites[i].visible = (i < @max)
          @sprite_lifetimes[i] = 0
        end
      end
      if @fading && @new_sprites.length < MAX_SPRITES && @weatherTypes[@target_type] &&
        @weatherTypes[@target_type][1].length > 0
        for i in 0...MAX_SPRITES
          if !@new_sprites[i]
            sprite = Sprite.new(@origViewport)
            sprite.z       = 1000
            sprite.ox      = @ox
            sprite.oy      = @oy
            sprite.opacity = 0
            @new_sprites[i] = sprite
          end
          @new_sprites[i].visible = (i < @new_max)
          @new_sprite_lifetimes[i] = 0
        end
      end
    end

    def ensureTiles
      return if @tiles.length >= @tiles_wide * @tiles_tall
      for i in 0...(@tiles_wide * @tiles_tall)
        if !@tiles[i]
          sprite = Sprite.new(@origViewport)
          sprite.z       = 1000
          sprite.ox      = @ox
          sprite.oy      = @oy
          sprite.opacity = 0
          @tiles[i] = sprite
        end
        @tiles[i].visible = true
      end
    end

    def set_sprite_bitmap(sprite, index, weather_type)
      return if !sprite
      weatherBitmaps = (@weatherTypes[weather_type]) ? @weatherTypes[weather_type][1] : nil
      if !weatherBitmaps || weatherBitmaps.length == 0
        sprite.bitmap = nil
        return
      end
      if @weatherTypes[weather_type][0].category == :Rain
        last_index = weatherBitmaps.length - 1
        if (index % 2) == 0
          sprite.bitmap = weatherBitmaps[index % last_index]
        else
          sprite.bitmap = weatherBitmaps[last_index]
        end
      else
        sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      end
    end

    def set_tile_bitmap(sprite, index, weather_type)
      return if !sprite || !weather_type
      weatherBitmaps = (@weatherTypes[weather_type]) ? @weatherTypes[weather_type][2] : nil
      if weatherBitmaps && weatherBitmaps.length > 0
        sprite.bitmap = weatherBitmaps[index % weatherBitmaps.length]
      else
        sprite.bitmap = nil
      end
    end

    def reset_sprite_position(sprite, index, is_new_sprite = false)
      weather_type = (is_new_sprite) ? @target_type : @type
      lifetimes = (is_new_sprite) ? @new_sprite_lifetimes : @sprite_lifetimes
      if index < (is_new_sprite ? @new_max : @max)
        sprite.visible = true
      else
        sprite.visible = false
        lifetimes[index] = 0
        return
      end
      if @weatherTypes[weather_type][0].category == :Rain && (index % 2) != 0
        sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width * 2)
        sprite.y = @oy - sprite.bitmap.height + rand(Graphics.height + sprite.bitmap.height * 2)
        lifetimes[index] = (30 + rand(20)) * 0.01
      else
        x_speed = @weatherTypes[weather_type][0].particle_delta_x
        y_speed = @weatherTypes[weather_type][0].particle_delta_y
        gradient = x_speed.to_f / y_speed
        if gradient.abs >= 1
          sprite.x = @ox + Graphics.width + rand(Graphics.width)
          sprite.y = @oy + Graphics.height - rand(Graphics.height + sprite.bitmap.height - Graphics.width / gradient)
          distance_to_cover = sprite.x - @ox - Graphics.width / 2 + sprite.bitmap.width + rand(Graphics.width * 8 / 5)
          lifetimes[index] = (distance_to_cover.to_f / x_speed).abs
        else
          sprite.x = @ox - sprite.bitmap.width + rand(Graphics.width + sprite.bitmap.width - gradient * Graphics.height)
          sprite.y = @oy - sprite.bitmap.height - rand(Graphics.height)
          distance_to_cover = @oy - sprite.y + Graphics.height / 2 + rand(Graphics.height * 8 / 5)
          lifetimes[index] = (distance_to_cover.to_f / y_speed).abs
        end
      end
      sprite.opacity = 100
    end

    def update_sprite_position(sprite, index, is_new_sprite = false)
      return if !sprite || !sprite.bitmap || !sprite.visible
      delta_t = Graphics.delta_s
      lifetimes = (is_new_sprite) ? @new_sprite_lifetimes : @sprite_lifetimes
      if lifetimes[index] >= 0
        lifetimes[index] -= delta_t
        if lifetimes[index] <= 0
          reset_sprite_position(sprite, index, is_new_sprite)
          return
        end
      end
      weather_type = (is_new_sprite) ? @target_type : @type
      if @weatherTypes[weather_type][0].category == :Rain && (index % 2) != 0
        sprite.opacity = (lifetimes[index] < 0.4) ? 255 : 0
      else
        dist_x = @weatherTypes[weather_type][0].particle_delta_x * delta_t
        dist_y = @weatherTypes[weather_type][0].particle_delta_y * delta_t
        sprite.x += dist_x
        sprite.y += dist_y
        if weather_type == :Snow
          sprite.x += dist_x * (sprite.y - @oy) / (Graphics.height * 3)
          sprite.x += [2, 1, 0, -1][rand(4)] * dist_x / 8
          sprite.y += [2, 1, 1, 0, 0, -1][index % 6] * dist_y / 10
        end
        if weather_type == :StrongWinds || weather_type == :Wind
          sprite.opacity-=[20, 0, 10, -10][rand(4)]
        end
        sprite.opacity += @weatherTypes[weather_type][0].particle_delta_opacity * delta_t
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64 || x < -sprite.bitmap.width || y > Graphics.height
          reset_sprite_position(sprite, index, is_new_sprite)
        end
      end
    end

    def recalculate_tile_positions
      delta_t = Graphics.delta_s
      weather_type = @type
      if @fading && @fade_time >= [FADE_OLD_TONE_END - @time_shift, 0].max
        weather_type = @target_type
      end
      @tile_x += @weatherTypes[weather_type][0].tile_delta_x * delta_t
      @tile_y += @weatherTypes[weather_type][0].tile_delta_y * delta_t
      if @tile_x < -@tiles_wide * @weatherTypes[weather_type][2][0].width
        @tile_x += @tiles_wide * @weatherTypes[weather_type][2][0].width
      end
      if @tile_y > @tiles_tall * @weatherTypes[weather_type][2][0].height
        @tile_y -= @tiles_tall * @weatherTypes[weather_type][2][0].height
      end
    end

    def update_tile_position(sprite, index)
      return if $PokemonSystem.on_mobile
      return if !sprite || !sprite.bitmap || !sprite.visible
      sprite.x = (@ox + @tile_x + (index % @tiles_wide) * sprite.bitmap.width).round
      sprite.y = (@oy + @tile_y + (index / @tiles_wide) * sprite.bitmap.height).round
      sprite.x += @tiles_wide * sprite.bitmap.width if sprite.x - @ox < -sprite.bitmap.width
      sprite.y -= @tiles_tall * sprite.bitmap.height if sprite.y - @oy > Graphics.height
      sprite.visible = true
      if @fading && @type != @target_type
        if @fade_time >= FADE_OLD_TILES_START && @fade_time < FADE_OLD_TILES_END
          if @time_shift == 0
            fraction = (@fade_time - [FADE_OLD_TILES_START - @time_shift, 0].max) / (FADE_OLD_TILES_END - FADE_OLD_TILES_START)
            sprite.opacity = 255 * (1 - fraction)
          end
        elsif @fade_time >= [FADE_NEW_TILES_START - @time_shift, 0].max &&
          @fade_time < [FADE_NEW_TILES_END - @time_shift, 0].max
          fraction = (@fade_time - [FADE_NEW_TILES_START - @time_shift, 0].max) / (FADE_NEW_TILES_END - FADE_NEW_TILES_START)
          sprite.opacity = 255 * fraction
        else
          sprite.opacity = 0
        end
      else
        sprite.opacity = (@max > 0) ? 255 : 0
      end
    end

    def update_screen_tone
      weather_type = @type
      weather_max = @max
      fraction = 1
      tone_red = tone_green = tone_blue = tone_gray = 0
      if @fading
        if @type == @target_type
          if @fade_time >= [FADE_NEW_TONE_START - @time_shift, 0].max &&
            @fade_time < [FADE_NEW_TONE_END - @time_shift, 0].max
            weather_max = @target_max
            fract = (@fade_time - [FADE_NEW_TONE_START - @time_shift, 0].max) / (FADE_NEW_TONE_END - FADE_NEW_TONE_START)
            tone_red = @target_tone.red + (1 - fract) * (@old_tone.red - @target_tone.red)
            tone_green = @target_tone.green + (1 - fract) * (@old_tone.green - @target_tone.green)
            tone_blue = @target_tone.blue + (1 - fract) * (@old_tone.blue - @target_tone.blue)
            tone_gray = @target_tone.gray + (1 - fract) * (@old_tone.gray - @target_tone.gray)
          else
            tone_red = @viewport.tone.red
            tone_green = @viewport.tone.green
            tone_blue = @viewport.tone.blue
            tone_gray = @viewport.tone.gray
          end
        elsif @time_shift < 2 && @fade_time >= FADE_OLD_TONE_START && @fade_time < FADE_OLD_TONE_END
          weather_max = @old_max
          fraction = ((@fade_time - FADE_OLD_TONE_START) / (FADE_OLD_TONE_END - FADE_OLD_TONE_START)).clamp(0, 1)
          fraction = 1 - fraction
          tone_red = @old_tone.red
          tone_green = @old_tone.green
          tone_blue = @old_tone.blue
          tone_gray = @old_tone.gray
        elsif @fade_time >= [FADE_NEW_TONE_START - @time_shift, 0].max
          weather_type = @target_type
          weather_max = @target_max
          fraction = ((@fade_time - [FADE_NEW_TONE_START - @time_shift, 0].max) / (FADE_NEW_TONE_END - FADE_NEW_TONE_START)).clamp(0, 1)
          tone_red = @target_tone.red
          tone_green = @target_tone.green
          tone_blue = @target_tone.blue
          tone_gray = @target_tone.gray
        end
      else
        base_tone = get_weather_tone(weather_type, weather_max)
        tone_red = base_tone.red
        tone_green = base_tone.green
        tone_blue = base_tone.blue
        tone_gray = base_tone.gray
      end
      if weather_type == :Sun
        @sun_magnitude = weather_max if @sun_magnitude != weather_max && @sun_magnitude != -weather_max
        @sun_magnitude *= -1 if (@sun_magnitude > 0 && @sun_strength > @sun_magnitude) ||
          (@sun_magnitude < 0 && @sun_strength < 0)
        @sun_strength += @sun_magnitude.to_f * Graphics.delta_s / 0.4
        tone_red += @sun_strength
        tone_green += @sun_strength
        tone_blue += @sun_strength / 2
      end
      @viewport.tone.set(tone_red * fraction, tone_green * fraction,
                         tone_blue * fraction, tone_gray * fraction)
    end

    def update_fading
      return if !@fading
      old_fade_time = @fade_time
      @fade_time += Graphics.delta_s

      # 1. Tile Bitmap Swap Logic
      if @type != @target_type
        tile_change_threshold = [FADE_OLD_TONE_END - @time_shift, 0].max
        if old_fade_time <= tile_change_threshold && @fade_time > tile_change_threshold
          @tile_x = @tile_y = 0.0
          if @weatherTypes[@target_type] && @weatherTypes[@target_type][2].length > 0
            w = @weatherTypes[@target_type][2][0].width
            h = @weatherTypes[@target_type][2][0].height
            @tiles_wide = (Graphics.width.to_f / w).ceil + 1
            @tiles_tall = (Graphics.height.to_f / h).ceil + 1
            ensureTiles
            @tiles.each_with_index { |sprite, i| set_tile_bitmap(sprite, i, @target_type) }
          else
            @tiles_wide = @tiles_tall = 0
          end
        end
      end

      # 2. INDEPENDENT FOG LOGIC (Targeting Current Map Only)
      f_end = FADE_FOG_OPACITY_END
      if @fade_time <= f_end
        fraction = (@fade_time / f_end).clamp(0.0, 1.0)
        current_opacity = (@start_opacity + (@end_opacity - @start_opacity) * fraction).to_i

        # ONLY apply to the map the player is currently on
        map = $game_map
        if @target_type == :None
          # Keep existing fog graphic while fading out
          old_w = GameData::Weather.get(@type)
          map.fog_name = old_w.fog_name if old_w && map.fog_name.nil?
        else
          target_weather = GameData::Weather.get(@target_type)
          map.fog_name = target_weather.fog_name
          map.fog_sx   = target_weather.tile_delta_x
          map.fog_sy   = target_weather.tile_delta_y
        end
        map.fog_opacity = current_opacity

        # IMPORTANT: Clear fog on all OTHER loaded maps so they don't stack
        $MapFactory.maps.each do |m|
          next if m.map_id == $game_map.map_id
          m.fog_opacity = 0
          m.fog_name = nil
        end
      end

      # 3. Particle Fade Logic (Old Particles Out)
      if @max > 0 && @fade_time >= [FADE_OLD_PARTICLES_START - @time_shift, 0].max
        p_fade_start = [FADE_OLD_PARTICLES_START - @time_shift, 0].max
        fraction = (@fade_time - p_fade_start) / (FADE_OLD_PARTICLES_END - FADE_OLD_PARTICLES_START)
        @max = @old_max * (1 - fraction.clamp(0, 1))
      end

      # 4. Particle Fade Logic (New Particles In)
      if @new_max < @target_max && @fade_time >= [FADE_NEW_PARTICLES_START - @time_shift, 0].max
        p_in_start = [FADE_NEW_PARTICLES_START - @time_shift, 0].max
        fraction = (@fade_time - p_in_start) / (FADE_NEW_PARTICLES_END - FADE_NEW_PARTICLES_START)
        @new_max = (@target_max * fraction.clamp(0, 1)).floor
        @new_sprites.each_with_index { |sprite, i| sprite.visible = (i < @new_max) if sprite }
      end

      # 5. End Condition
      particle_end_time = ((@target_type == :None) ? FADE_OLD_PARTICLES_END : FADE_NEW_TILES_END) - @time_shift
      if @fade_time >= [particle_end_time, f_end].max # FIXED: fade_end to f_end
        if !@sprites.any? { |sprite| sprite.visible } || @fade_time > f_end + 1
          @type                 = @target_type
          @max                  = @target_max
          set_fog(@type)
          @target_type          = nil
          @target_max           = nil
          @old_max              = nil
          @new_max              = nil
          @old_tone             = nil
          @target_tone          = nil
          @fade_time            = 0.0
          @time_shift           = 0
          @sprites.each { |sprite| sprite.dispose if sprite }
          @sprites              = @new_sprites
          @new_sprites          = []
          @sprite_lifetimes     = @new_sprite_lifetimes
          @new_sprite_lifetimes = []
          @fading               = false
        end
      end
    end

    def update
      update_fading
      update_screen_tone
      if @type == :Storm && !@fading
        if @time_until_flash > 0
          @time_until_flash -= Graphics.delta_s
          if @time_until_flash <= 0
            @viewport.flash(Color.new(255, 255, 255, 230), (2 + rand(3)) * 20)
            if rand < 0.1
              @lightning_overlay.opacity = 255
              @lightning_overlay_duration = 20
              @lightning_overlay.y = rand(-200..0)
              @lightning_overlay.x = [-200,-150,150, 250].sample
            end
          end
        end
        if @time_until_flash <= 0
          @time_until_flash = (1 + rand(12)) * 0.5
        end
      end
      if @lightning_overlay_duration && @lightning_overlay_duration > 0
        @lightning_overlay_duration -= 1
        @lightning_overlay.opacity = (255 * (@lightning_overlay_duration / 10.0)).to_i
      else
        @lightning_overlay.opacity = 0 if @lightning_overlay
        @lightning_overlay_duration = nil
      end
      @viewport.update
      if @weatherTypes[@type] && @weatherTypes[@type][1].length > 0
        ensureSprites
        for i in 0...MAX_SPRITES
          update_sprite_position(@sprites[i], i, false)
        end
      elsif @sprites.length > 0
        @sprites.each { |sprite| sprite.dispose if sprite }
        @sprites.clear
      end
      if @fading && @weatherTypes[@target_type] && @weatherTypes[@target_type][1].length > 0
        ensureSprites
        for i in 0...MAX_SPRITES
          update_sprite_position(@new_sprites[i], i, true)
        end
      elsif @new_sprites.length > 0
        @new_sprites.each { |sprite| sprite.dispose if sprite }
        @new_sprites.clear
      end
      if @tiles_wide > 0 && @tiles_tall > 0
        ensureTiles
        recalculate_tile_positions
        @tiles.each_with_index { |sprite, i| update_tile_position(sprite, i) }
      elsif @tiles.length > 0
        @tiles.each { |sprite| sprite.dispose if sprite }
        @tiles.clear
      end
    end
  end
end