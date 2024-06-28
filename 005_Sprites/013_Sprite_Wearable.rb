class Sprite_Wearable < RPG::Sprite
  attr_accessor :filename
  attr_accessor :action
  attr_accessor :sprite

  def initialize(player_sprite, filename, action, viewport)
    @player_sprite = player_sprite
    @viewport = viewport
    @sprite = Sprite.new(@viewport)
    @wearableBitmap = AnimatedBitmap.new(filename) if pbResolveBitmap(filename)
    @filename = filename
    @sprite.bitmap = @wearableBitmap.bitmap if @wearableBitmap
    @action = action
    @color = 0
    @frameWidth = 80  #@sprite.width
    @frameHeight = 80 #@sprite.height / 4
    @sprite.z = 0
    @relative_z=0 #relative to player
    echoln(_INTL("init had at z = {1}, player sprite at {2}",@sprite.z,@player_sprite.z))

    #Unused position offset
    # @x_pos_base_offset = 0
    # @y_pos_base_offset = 0
  end

  def apply_sprite_offset(offsets_array, current_frame)
    @sprite.x  += offsets_array[current_frame][0]
    @sprite.y  += offsets_array[current_frame][1]
  end

  def set_sprite_position(action, direction, current_frame)
    @sprite.x = @player_sprite.x - @player_sprite.ox
    @sprite.y = @player_sprite.y - @player_sprite.oy
    case action
    when "run"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_UP, current_frame)
      end
    when "surf"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_DOWN,current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_LEFT,current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_RIGHT,current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_UP,current_frame)
      end
    when "dive"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_DOWN,current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_LEFT,current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_RIGHT,current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_UP,current_frame)
      end
    when "bike"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_DOWN,current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_LEFT,current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_RIGHT,current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_UP,current_frame)
      end
    else
      @sprite.x = @player_sprite.x - @player_sprite.ox
      @sprite.y = @player_sprite.y - @player_sprite.oy
    end
    @sprite.y -= 2 if current_frame % 2 == 1
  end

  def animate(action)
    @action = action
    current_frame = @player_sprite.character.pattern
    direction = @player_sprite.character.direction
    crop_spritesheet(direction)
    set_sprite_position(@action, direction, current_frame)
    adjust_layer()
  end

  def update(action, filename,color)
    @sprite.opacity = @player_sprite.opacity if @wearableBitmap
    if filename != @filename || color != @color
      if pbResolveBitmap(filename)
        #echoln pbResolveBitmap(filename)
        @wearableBitmap = AnimatedBitmap.new(filename,color)
        @sprite.bitmap = @wearableBitmap.bitmap
      else
        @wearableBitmap = nil
        @sprite.bitmap = nil
      end
      @color =color
      @filename = filename
    end
    animate(action)
  end

  def adjust_layer()
    if @sprite.z != @player_sprite.z+@relative_z
      @sprite.z = @player_sprite.z+@relative_z
    end
  end

  def crop_spritesheet(direction)
    sprite_x = 0
    sprite_y = ((direction - 2) / 2) * @frameHeight
    @sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  # def getCurrentSpriteOffset()
  #   direction = @character.direction
  #   current_frame = @character.pattern
  #   case @character_name
  #   when "run"
  #     if direction == DIRECTION_DOWN
  #       return Outfit_Offsets::RUN_OFFSETS_DOWN[current_frame]
  #     elsif direction == DIRECTION_LEFT
  #       return Outfit_Offsets::RUN_OFFSETS_LEFT[current_frame]
  #     elsif direction == DIRECTION_RIGHT
  #       return Outfit_Offsets::RUN_OFFSETS_RIGHT[current_frame]
  #     elsif direction == DIRECTION_UP
  #       return Outfit_Offsets::RUN_OFFSETS_UP[current_frame]
  #     end
  #   when "surf"
  #     #when "dive"
  #     if direction == DIRECTION_DOWN
  #       return Outfit_Offsets::SURF_OFFSETS_DOWN[current_frame]
  #     elsif direction == DIRECTION_LEFT
  #       return Outfit_Offsets::SURF_OFFSETS_LEFT[current_frame]
  #     elsif direction == DIRECTION_RIGHT
  #       return Outfit_Offsets::SURF_OFFSETS_RIGHT[current_frame]
  #     elsif direction == DIRECTION_UP
  #       return Outfit_Offsets::SURF_OFFSETS_UP[current_frame]
  #     end
  #   when "dive"
  #     if direction == DIRECTION_DOWN
  #       return Outfit_Offsets::DIVE_OFFSETS_DOWN[current_frame]
  #     elsif direction == DIRECTION_LEFT
  #       return Outfit_Offsets::DIVE_OFFSETS_LEFT[current_frame]
  #     elsif direction == DIRECTION_RIGHT
  #       return Outfit_Offsets::DIVE_OFFSETS_RIGHT[current_frame]
  #     elsif direction == DIRECTION_UP
  #       return Outfit_Offsets::DIVE_OFFSETS_UP[current_frame]
  #     end
  #   when "bike"
  #     if direction == DIRECTION_DOWN
  #       return Outfit_Offsets::BIKE_OFFSETS_DOWN[current_frame]
  #     elsif direction == DIRECTION_LEFT
  #       return Outfit_Offsets::BIKE_OFFSETS_LEFT[current_frame]
  #     elsif direction == DIRECTION_RIGHT
  #       return Outfit_Offsets::BIKE_OFFSETS_RIGHT[current_frame]
  #     elsif direction == DIRECTION_UP
  #       return Outfit_Offsets::BIKE_OFFSETS_UP[current_frame]
  #     end
  #   end
  #   return Outfit_Offsets::BASE_OFFSET[current_frame]
  # end


end
