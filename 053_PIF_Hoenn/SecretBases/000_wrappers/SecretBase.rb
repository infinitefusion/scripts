# frozen_string_literal: true

class SecretBase
  attr_reader :outside_map_id #Id of the map where the secret base is
  attr_reader :inside_map_id #Id of the secret base's map itself

  attr_reader :location_name #Name of the Route where the secret base is in plain text


  attr_reader :outside_entrance_position #Fly coordinates
  attr_reader :inside_entrance_position #Where the player gets warped

  attr_reader :type #:CAVE, :TREE,
  attr_accessor :base_name

  attr_accessor :layout


  def initialize(type,outside_map_id,outside_entrance_position, inside_map_id,inside_entrance_position)
    @type = type
    @outside_map_id = outside_map_id
    @inside_map_id = inside_map_id

    @outside_entrance_position = outside_entrance_position
    @inside_entrance_position = inside_entrance_position

    initializeLayout
  end

  def initializeLayout
    @layout = SecretBaseLayout.new

    entrance_x = @inside_entrance_position[0]
    entrance_y = @inside_entrance_position[1]

    @layout.add_item(:PC,[entrance_x,entrance_y-2])
  end
end
