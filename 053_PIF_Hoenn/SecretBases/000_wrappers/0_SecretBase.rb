# frozen_string_literal: true

class SecretBase
  attr_reader :outside_map_id #Id of the map where the secret base is
  attr_reader :inside_map_id #Id of the secret base's map itself

  attr_reader :location_name #Name of the Route where the secret base is in plain text


  attr_reader :outside_entrance_position #Fly coordinates
  attr_reader :inside_entrance_position #Where the player gets warped

  attr_reader :biome_type #:CAVE, :TREE,
  attr_reader :base_layout_type
  attr_accessor :base_name
  attr_accessor :base_message

  attr_accessor :layout


  def initialize(biome,outside_map_id,outside_entrance_position, inside_map_id,base_layout_type)
    @biome_type = biome
    @outside_map_id = outside_map_id
    @inside_map_id = inside_map_id

    @outside_entrance_position = outside_entrance_position
    @base_layout_type = base_layout_type.to_sym

    @inside_entrance_position = SecretBasesData::SECRET_BASE_ENTRANCES[@base_layout_type][:position]

    @base_name=initializeBaseName
    @base_message=initialize_base_message #For a book or sign item that allows to set a custom message
    initializeLayout
  end

  def initializeBaseName
    return _INTL("#{$Trainer.name}'s secret base")
  end

  def initialize_base_message
    return "Welcome to my secret base!"
  end
  def initializeLayout
    @layout = SecretBaseLayout.new(@base_layout_type)

    entrance_x = @inside_entrance_position[0]
    entrance_y = @inside_entrance_position[1]

    @layout.add_item(:PC,[entrance_x,entrance_y-3])
  end
end
