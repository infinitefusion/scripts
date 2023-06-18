class FusionQuiz

  #
  # Possible difficulties:
  #
  # :REGULAR -> 4 options choice
  #
  # :ADVANCED -> List of all pokemon
  #
  def initialize(difficulty = :REGULAR)
    @sprites      = {}

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)

    @difficulty = difficulty
    @customs_list = getCustomSpeciesList(true, false)
    @selected_pokemon = nil
    @head_id = nil
    @body_id = nil
    @choices = []

    @score = 0
  end

  def start_quiz_round()
    pick_random_pokemon()
    show_fusion_picture(true)

    #QUESTION 1
    new_question(500, "What Pokémon is this fusion's body?",@body_id,true)
    pbMessage("Next question!")
    new_question(500,"What Pokémon is this fusion's head?", @head_id,true)
    @viewport.dispose

    show_fusion_picture(false )
    #QUESTION 1
    new_question(200, "What Pokémon is this fusion's body?",@body_id,true)
    pbMessage("Next question!")
    new_question(200,"What Pokémon is this fusion's head?", @head_id,true)
    @viewport.dispose

  end


  def new_question(points_value,question, answer_id, should_generate_new_choices)
    answer_name = getPokemon(answer_id).real_name
    answered_correctly = give_answer(question,answer_id,should_generate_new_choices)
    award_points(points_value) if answered_correctly
    question_answer_followup_dialog(answered_correctly,answer_name,points_value,true)
  end



  def award_points(nb_points)
    @score += nb_points
  end

  def question_answer_followup_dialog(answered_correctly,correct_answer, points_awarded_if_win, other_chance_later=false)
    pbMessage("And the correct answer was...")
    pbMessage("...")
    pbMessage(_INTL("{1}!",correct_answer))
    if answered_correctly
      pbMessage("That's a correct answer!")
      pbMessage(_INTL("You're awarded {1} points your answer. Your current score is {2}",points_awarded_if_win,@score.to_s))
    else
      pbMessage("Unfortunately, you didn't get the answer right. ")
      pbMessage("But you'll get another chance later!") if other_chance_later
    end
  end


  def show_fusion_picture(obscured = false)
    picturePath = get_fusion_sprite_path(@head_id, @body_id)
    bitmap = AnimatedBitmap.new(picturePath)
    bitmap.scale_bitmap(Settings::FRONTSPRITE_SCALE)
    previewwindow = PictureWindow.new(bitmap)
    previewwindow.y = 30
    previewwindow.x = 100
    previewwindow.z = 100000
    if obscured
      previewwindow.picture.pbSetColor(255, 255, 255, 200)
    end
  end

  def pick_random_pokemon(save_in_variable = 1)
    random_pokemon = getRandomCustomFusionForIntro(true, @customs_list)
    @head_id = random_pokemon[0]
    @body_id = random_pokemon[1]
    @selected_pokemon = getSpeciesIdForFusion(@head_id, @body_id)
    pbSet(save_in_variable, @selected_pokemon)
  end

  def give_answer(prompt_message,answer_id,should_generate_new_choices)
    question_answered=false
    answer_pokemon_name = getPokemon(answer_id).real_name

    while !question_answered
      if @difficulty == :ADVANCED
        player_answer = prompt_pick_answer_advanced(prompt_message,answer_id)
      else
        player_answer = prompt_pick_answer_regular(prompt_message,answer_id,should_generate_new_choices)
      end
      confirmed = pbMessage("Is that your final answer?",["Yes","No"])
      if confirmed==0
        question_answered=true
      end
    end
    return player_answer == answer_pokemon_name
  end

  def get_random_pokemon_from_same_egg_group(pokemon,previous_choices)
    egg_groups = getPokemonEggGroups(pokemon)
    while true
      new_pokemon = rand(NB_POKEMON+1)
      new_pokemon_egg_groups = getPokemonEggGroups(new_pokemon)
      if (egg_groups & new_pokemon_egg_groups).any? && !previous_choices.include?(new_pokemon)
        return new_pokemon
      end
    end
  end

  def prompt_pick_answer_regular(prompt_message,real_answer,should_new_choices)
    commands = should_new_choices ? generate_new_choices(real_answer) : @choices
    chosen = pbMessage(prompt_message,commands)
    #chosen = pbChooseList(commands, 0, nil, 1)
    return commands[chosen]
  end

  def generate_new_choices(real_answer)
    choices = []
    choices << real_answer
    choices << get_random_pokemon_from_same_egg_group(real_answer,choices)
    choices << get_random_pokemon_from_same_egg_group(real_answer,choices)
    choices << get_random_pokemon_from_same_egg_group(real_answer,choices)

    commands = []
    choices.each do |dex_num, i|
      species = getPokemon(dex_num)
      commands.push(species.real_name)
    end
    @choices = commands
    return commands.shuffle
  end


  def prompt_pick_answer_advanced(prompt_message,answer)
    choices.each do |dex_num, i|
      species = getPokemon(dex_num)
      commands.push([i, species.real_name, species.real_name])
    end
    pbMessage(prompt_message)
    #chosen = pbChooseList(commands, 0, nil, 1)

  end

end
