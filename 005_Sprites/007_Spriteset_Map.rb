# Unused
class ClippableSprite < Sprite_Character
  def initialize(viewport,event,tilemap)
    @tilemap = tilemap
    @_src_rect = Rect.new(0,0,0,0)
    super(viewport,event)
  end

  def update
    super
    @_src_rect = self.src_rect
    tmright = @tilemap.map_data.xsize*Game_Map::TILE_WIDTH-@tilemap.ox
    echoln("x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}")
    if @tilemap.ox-self.ox<-self.x
      # clipped on left
      diff = -self.x-@tilemap.ox+self.ox
      self.src_rect = Rect.new(@_src_rect.x+diff,@_src_rect.y,
                               @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    elsif tmright-self.ox<self.x
      # clipped on right
      diff = self.x-tmright+self.ox
      self.src_rect = Rect.new(@_src_rect.x,@_src_rect.y,
                               @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out right: #{diff} #{tmright+self.ox} #{self.x}")
    else
      echoln("-not- clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    end
  end
end



class Spriteset_Map
  attr_reader :map
  @@viewport0 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Panorama
  @@viewport0.z = -100
  @@viewport1 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Map, events, player, fog
  @@viewport1.z = 0
  @@viewport3 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Flashing
  @@viewport3.z = 500

  def Spriteset_Map.viewport   # For access by Spriteset_Global
    return @@viewport1
  end

  def initialize(map=nil)
    @map = (map) ? map : $game_map
    $scene.map_renderer.add_tileset(@map.tileset_name)
    @map.autotile_names.each do |filename|
      $scene.map_renderer.add_autotile(filename)
      $scene.map_renderer.add_extra_autotiles(@map.tileset_id,@map.map_id)
    end

    @panorama = AnimatedPlane.new(@@viewport0)
    @fog = AnimatedPlane.new(@@viewport1)
    @fog.z = 3000
    @fog2=nil
    @character_sprites = []
    for i in @map.events.keys.sort
      sprite = Sprite_Character.new(@@viewport1,@map.events[i])
      @character_sprites.push(sprite)
    end
    @weather = RPG::Weather.new(@@viewport1)
    pbOnSpritesetCreate(self,@@viewport1)
    update
  end

  def setFog2(filename="010-Water04")
    disposeFog2()
    @fog2 = AnimatedPlane.new(@@viewport1)
    @fog2.z = 3001
    @fog2.setFog(filename)
  end

  def disposeFog2()
    @fog2.dispose if @fog2
    @fog2 =nil
  end

  def dispose
    if $scene.is_a?(Scene_Map)
      $scene.map_renderer.remove_tileset(@map.tileset_name)
      @map.autotile_names.each do |filename|
        $scene.map_renderer.remove_autotile(filename)
        $scene.map_renderer.remove_extra_autotiles(@map.tileset_id)
      end
    end
    @panorama.dispose
    @fog.dispose
    @fog2.dispose if @fog2
    for sprite in @character_sprites
      sprite.dispose
    end
    @weather.dispose
    @panorama = nil
    @fog = nil
    @character_sprites.clear
    @weather = nil
  end

  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites = anims
  end

  def update
    if @panorama_name!=@map.panorama_name || @panorama_hue!=@map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue  = @map.panorama_hue
      @panorama.setPanorama(nil) if @panorama.bitmap!=nil
      @panorama.setPanorama(@panorama_name,@panorama_hue) if @panorama_name!=""
      Graphics.frame_reset
    end
    if @fog_name!=@map.fog_name || @fog_hue!=@map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      @fog.setFog(nil) if @fog.bitmap!=nil
      @fog.setFog(@fog_name,@fog_hue) if @fog_name!=""
      Graphics.frame_reset
    end
    tmox = (@map.display_x/Game_Map::X_SUBPIXELS).round
    tmoy = (@map.display_y/Game_Map::Y_SUBPIXELS).round
    @@viewport1.rect.set(0,0,Graphics.width,Graphics.height)
    @@viewport1.ox = 0
    @@viewport1.oy = 0
    @@viewport1.ox += $game_screen.shake
    @panorama.ox = tmox/2
    @panorama.oy = tmoy/2
    @fog.ox         = tmox+@map.fog_ox
    @fog.oy         = tmoy+@map.fog_oy
    @fog.zoom_x     = @map.fog_zoom/100.0
    @fog.zoom_y     = @map.fog_zoom/100.0
    @fog.opacity    = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.tone       = @map.fog_tone

    @fog2.ox         = tmox+@map.fog2_ox if @fog2
    @fog2.oy         = tmoy+@map.fog2_oy if @fog2
    @fog2.zoom_x     = @map.fog_zoom/100.0 if @fog2
    @fog2.zoom_y     = @map.fog_zoom/100.0 if @fog2
    @fog2.opacity    = @map.fog2_opacity if @fog2


    @panorama.update
    @fog.update
    @fog2.update if @fog2

    for sprite in @character_sprites
      sprite.update
    end
    if self.map!=$game_map
      #@weather.fade_in(:None, 0, 20)
    else
      @weather.fade_in($game_screen.weather_type, $game_screen.weather_power, $game_screen.weather_duration)
    end
    @weather.ox   = tmox
    @weather.oy   = tmoy
    @weather.update
    @@viewport1.tone = $game_screen.tone
    @@viewport3.color = $game_screen.flash_color
    @@viewport1.update
    @@viewport3.update
  end
end
