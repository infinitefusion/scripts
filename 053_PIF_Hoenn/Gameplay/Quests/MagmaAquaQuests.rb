def build_magma_song(event_id1, event_id2)
  chorus = _INTL("Ma\\wt[10]gma!\\n\\wt[5]Team Ma\\wt[10]gma!")
  add_magma_song_segment(chorus)
  segment1 = build_magma_song_pt1(event_id1, event_id2,chorus)
  build_magma_song_pt2(event_id1, event_id2)
  add_magma_song_segment(chorus)
  add_magma_song_segment(segment1)
  build_magma_song_pt3(event_id1, event_id2)

end

def build_magma_song_pt1(event_id1, event_id2,chorus)
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Let's see, this is what we have so far."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("The start of the song goes like this..."))

  #~~~~~ Singing ~~~~~~
  segment_1_incomplete = _INTL("Hot as...\\wt[20]\\ts[1]Something...\\ts[4]\\wt[10]\\nFierce like...\\wt[20]\\ts[1]Something else...")
  add_magma_song_segment(segment_1_incomplete)
  sing_magma_song
  pbWait(10)
  #~~~~~~~~~~~

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Yeah... That's all we have so far."))

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("So uh... What's something that's burning hot?"))

    helpText = _INTL("Hot as...")
    word1 = pbEnterText(helpText, 2, 16)

    pbCallBubDown(2, event_id1) # Left
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Hot as {1}...?", word1), commands) == 0
  end

  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("Hmmm..."))
  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("I like it! Let's go with this!"))
  pbWait(10)

  #~~~~~ Singing ~~~~~~
  pbSet(VAR_MAGMA_SONG, [])
  add_magma_song_segment(chorus)
  segment_1_incomplete2 = _INTL("Hot as {1}!\\wt[10]\\nFierce like...\\wt[20]\\ts[1]Something...", word1)
  add_magma_song_segment(segment_1_incomplete2)
  sing_magma_song
  pbWait(10)
  #~~~~~~~~~~~

  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Uh... Fierce like what?"))
    helpText = _INTL("Fierce like...")
    word2 = pbEnterText(helpText, 2, 16)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("Hot as {1}! Fierce like {2}!", word1, word2), commands) == 0
  end

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("It has a nice ring to it, don't you think?"))

  pbSet(VAR_MAGMA_SONG, [])
  add_magma_song_segment(chorus)
  segment_1_complete = _INTL("Hot as {1}!\\wt[10]\\nFierce like {2}!", word1, word2)
  add_magma_song_segment(segment_1_complete)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Okay... On to the next part!"))

  return segment_1_complete
end

def build_magma_song_pt2(event_id1, event_id2)
  cmd_goals = _INTL("Our goals")
  cmd_style = _INTL("Our style")
  cmd_strength = _INTL("Our strength")
  commands = [cmd_goals, cmd_style, cmd_strength]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("So... What should the next line of the song be about?"), commands)
    pbCallBubDown(2, event_id1) # Left
    pbMessage(_INTL("Okay... How's this?"))
    case commands[choice]
    when cmd_goals
      segment1 = _INTL("\\ts[4]\\C[2]Land is the cradle of all\\n\\wt[5]We must ex\\wt[2]pand \\wt[2]its \\wt[2]sprawl!")
    when cmd_style
      segment1 = _INTL("\\ts[4]\\C[2]Our uniforms are sleek\\n\\wt[5]Our style is \\wt[6]unique!")
    when cmd_strength
      segment1 = _INTL("\\ts[4]\\C[2]No one can match our power\\n\\wt[5]We grow stronger \\wt[2]by \\wt[2]the \\wt[2]hour!")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment1, commands_confirm) == 0
  end
  add_magma_song_segment(segment1)


  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("That's pretty good!"))
  pbCallBubUp(2, event_id2) # Right
  pbMessage(_INTL("The next line should talk about something that inspires us."))
  cmd_leader = _INTL("Maxie")
  cmd_land = _INTL("The land")
  cmd_pokemon = _INTL("Pokémon")
  commands = [cmd_leader, cmd_land, cmd_pokemon]

  confirmed = false
  while !confirmed
    pbCallBubDown(2, event_id1) # Left
    choice = pbMessage(_INTL("What should we sing about?"), commands)
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Hmm... How about this?"))
    case commands[choice]
    when cmd_leader
      segment2 = _INTL("\\ts[4]\\C[2]Ma\\wt[2]xie's a visionary \\wt[5]\\nHis \\ts[2]intellect is \\wt[5]le\\wt[2]gen\\wt[2]da\\wt[4]ry")
    when cmd_land
      segment2 = _INTL("\\ts[4]\\C[2]The land is our domain\\wt[5]\\n\\ts[2]Magma flows \\wt[2]through \\wt[2]our \\wt[2]veins!")
    when cmd_pokemon
      segment2 = _INTL("\\ts[4]\\C[2]Land Po\\wt[2]ké\\wt[2]mon by our side\\wt[5]\\nThe oceans \\ts[2]will soon sub\\wt[5]side!")
    end

    commands_confirm = [_INTL("Perfect"), _INTL("Let's try something else...")]
    pbCallBubDown(2, event_id1) # Left
    confirmed = pbMessage(segment2, commands_confirm) == 0
  end
  add_magma_song_segment(segment2)

  pbCallBubDown(2, event_id1) # Left
  pbMessage(_INTL("Oh yeah that's pretty good."))
end

def build_magma_song_pt3(event_id1, event_id2)
  confirmed = false
  while !confirmed
    pbCallBubUp(2, event_id2) # Right
    pbMessage(_INTL("Now we only need an ending line. Do you have something in mind?"))
    helpText = _INTL("The song's final line...")
    line = pbEnterText(helpText, 2, 50)

    pbCallBubUp(2, event_id2) # Right
    commands = [_INTL("That's right!"), _INTL("Maybe not...")]
    confirmed = pbMessage(_INTL("{1}... ?", line), commands) == 0
  end
  add_magma_song_segment(line)
end


def sing_magma_song
  pbMEPlay("magma_theme_song")
  lyrics = pbGet(VAR_MAGMA_SONG)
  for line in lyrics
    line = "\\ts[4]\\C[2]#{line}\\wtnp[20]"
    pbCallBub(3)
    pbMessage(line)
  end
  pbMEStop
end

def add_magma_song_segment(text)
  current_song = pbGet(VAR_MAGMA_SONG)
  current_song = [] unless current_song.is_a?(Array)
  current_song << text
  pbSet(VAR_MAGMA_SONG, current_song)
end