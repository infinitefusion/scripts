class Game_Event < Game_Character


  #Detects if the event has a specific comment command at the top
  def detectCommentCommand(comment_text)
    page = pbGetActiveEventPage(event)
    first_command = page.list[0]
    return nil if !(first_command.code == 108 || first_command.code == 408)
    comments = first_command.parameters
    return comments.any? { |str| comment_text.include?(str) }
  end
end

