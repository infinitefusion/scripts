class PokemonChallenges_Scene
  VISIBLE_BUTTONS = 3 # Number of buttons visible at once
  Y_START = 40
  Y_GAP = 108

  def pbStartScene(challenges)
    @challenges = []
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Challenges/bg")

    # Buttons
    @buttons = []

    $Trainer.challenges.keys.each_with_index do |challenge_id, i|
      challenge = $Trainer.challenges[challenge_id]
      next unless challenge
      @challenges << challenge
      btn = ChallengeButton.new(challenge, 40, Y_START + i * Y_GAP, @viewport)
      @sprites["button#{i}"] = btn
      @buttons << btn
    end

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    # Update selection
    @buttons.each_with_index do |btn, idx|
      btn.selected = (idx == @index)
    end

    # Scroll calculation
    scroll_offset = 0
    if @index >= VISIBLE_BUTTONS
      scroll_offset = (@index - VISIBLE_BUTTONS + 1) * Y_GAP
    end

    # Move buttons according to scroll
    @buttons.each_with_index do |btn, idx|
      btn.y = Y_START + idx * Y_GAP - scroll_offset
    end

    pbUpdateSpriteHash(@sprites)
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate

      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        challenge = @challenges[@index]

        if @buttons[@index].can_claim_reward
          $Trainer.remove_challenge(challenge.id)
          removeChallengeAt(@index)
          pbUpdate
          pbSEPlay("GUI storage show party panel")
          receiveChallengeReward(challenge)
        else
          pbSEPlay("GUI sel buzzer",80)
          pbMessage(_INTL("The reward can only be collected once you complete the challenge!"))
        end
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @challenges.length > 1
        @index -= 1
        @index = @challenges.length - 1 if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @challenges.length > 1
        @index += 1
        @index = 0 if @index >= @challenges.length
      end
    end
  end

  def receiveChallengeReward(challenge)
    money_reward = challenge.money_reward
    item_reward = challenge.item_reward
    quantity = item_reward.length
    pbReceiveMoney(money_reward)
    pbReceiveItem(item_reward[0], quantity)
    $Trainer.money += money_reward

  end

  def challengeCompleted?(challenge_id)
    return $Trainer.completed_challenge?(challenge_id)
  end

  def removeChallengeAt(index)
    # Dispose sprite
    btn = @buttons[index]
    btn.dispose
    @sprites.delete_if { |_, v| v == btn }

    # Remove from arrays
    @buttons.delete_at(index)
    @challenges.delete_at(index)

    # Clamp index so it stays valid
    if @index >= @buttons.length
      @index = @buttons.length - 1
    end
    @index = 0 if @index < 0
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
