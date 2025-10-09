#A special type of event that is a Pokemon visible in the overworld. It flees if the player gets too close.
# Can either spawn naturally or be static


class OverworldPokemon
  def initialize()
    @pokemon = :PIKACHU #Can only be unfused
    @x=0
    @y=0
    @map_id=0

    @flying = false
    @always_on_top = false
    @stop_animation = false
    @detection_radius = 1

    @flee_graphics = nil #Possible to use a different sprite when fleeing (flying pokemon, etc.)
  end


end