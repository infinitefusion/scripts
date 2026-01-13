class Player

  def accept_challenge(challenge_id)
    @challenges = {} unless @challenges
    @challenges[challenge_id] = false
  end
  def complete_challenge(challenge_id)
    @challenges = {} unless @challenges
    if @challenges.has_key?(challenge_id)
      @challenges[challenge_id] = true
    end
  end


end

class Challenge
  attr_reader :id, :description, :category, :reward

  def initialize(id, description, category, reward)
    @id = id
    @description = description
    @reward = reward
  end
end

CHALLENGES = {}
def define_challenge(id, description:, category:, reward:)
  CHALLENGES[id] = Challenge.new(id, description, category, reward)
end

