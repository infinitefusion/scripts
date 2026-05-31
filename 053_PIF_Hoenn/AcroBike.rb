class Game_Player < Game_Character
  attr_accessor :bike_hops

  alias acroBike_update update
  def update
    acroBike_update
    check_bike_hopping
  end

  def check_bike_hopping
    return unless @bike_hops
    return if jumping?

    pbSEPlay("jump")
    dir = Input.dir4
    if dir > 0
      turn_generic(dir)
      if can_move_in_direction?(@direction)
        jumpForward
      else
        jump(0, 0)
      end
    else
      jump(0, 0)
    end
    $Trainer.stats.incr_nb_bike_hops
  end
end
