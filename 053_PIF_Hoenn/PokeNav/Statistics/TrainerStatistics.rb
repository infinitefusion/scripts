class TrainerStatistics
  attr_accessor :pokecenter_heals

  def initialize
    @pokecenter_heals = 0
    @nb_trades = 0
    @nb_battles_won = 0
    @nb_battles_lost = 0

    @nb_pokemon_defeated = 0
    @nb_pokemon_surprised = 0
  end

  def incr_nb_pokemon_surprised
    @nb_pokemon_surprised = 1 unless @nb_pokemon_surprised
    @nb_pokemon_surprised += 1
  end

  def incr_nb_pokemon_defeated
    @nb_pokemon_defeated = 1 unless @nb_pokemon_defeated
    @nb_pokemon_defeated += 1
    echoln @nb_pokemon_defeated
  end
  def incr_nb_trades
    @nb_trades = 1 unless @nb_trades
    @nb_trades += 1
  end

  def incr_nb_battles_won
    @nb_battles_won = 1 unless @nb_battles_won
    @nb_battles_won += 1
  end

  def incr_nb_battles_lost
    @nb_battles_lost = 1 unless @nb_battles_lost
    @nb_battles_lost += 1
  end
end