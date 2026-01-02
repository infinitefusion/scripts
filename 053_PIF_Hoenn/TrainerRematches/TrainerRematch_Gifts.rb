TRAINER_REMATCH_GIFTS = {
  # 2 tiers of gift.
  # common, rare
  # Odds depend on friendship level
  #
  # [[Tier 1], [Tier 2]]
  :NORMAL => [[:CHILANBERRY, :POTION, :FULLHEAL],
              [:UPGRADE]],
  :FIGHTING => [[:CHOPLEBERRY,],
                [:PROTEIN]],
  :FLYING => [[:COBABERRY, :PRETTYWING,],
              [:RAZORFANG]],
  :POISON => [[:KEBIABERRY, :ANTIDOTE],
              [:POISONBARB,],
              []],
  :GROUND => [[:SHUCABERRY,],
              [:SOFTSAND,]],
  :ROCK => [[:CHARTIBERRY, :HARDSTONE],
            [:STARDUST, :PROTECTOR]],
  :BUG => [[:TANGABERRY, :HONEY],
           [:BIGMUSHROOM]],
  :GHOST => [[:KASIBBERRY,],
             [:REAPERCLOTH]],
  :STEEL => [[:BABIRIBERRY,],
             [:METALCOAT, :METALPOWDER]],
  :FIRE => [[:BURNHEAL, :OCCABERRY],
            [:FIRESTONE, :LAVACOOKIE]],
  :WATER => [[:PASSHOBERRY, :HEARTSCALE],
             [:PEARL, :WATERSTONE]],
  :GRASS => [[:RINDOBERRY, :TINYMUSHROOM],
             [:LEAFSTONE]],
  :ELECTRIC => [[:PARLYZHEAL, :WACANBERRY],
                [:THUNDERSTONE]],
  :PSYCHIC => [[:PAYAPABERRY],
               [:MENTALHERB]],
  :ICE => [[:YACHEBERRY, :ICEHEAL],
           [:ICESTONE, :SNOWBALL]],
  :DRAGON => [[:HABANBERRY],
              [:DRAGONSCALE]],
  :DARK => [[:COLBURBERRY],
            [:RAZORCLAW]],
  :FAIRY => [[:ROSELIBERRY],
             [:WHIPPEDDREAM]],

  :ANY => [:DNASPLICERS, :DNAREVERSERS, :REPEL, :POTION, :GREATBALL]
}



def should_give_item(trainer)
  echoln trainer.friendship_level
  return false unless trainer.friendship_level >= 2
  base_rate = 10 #percent
  item_chances = base_rate+ (trainer.friendship/10).floor
  echoln item_chances
  return rand(100) < item_chances
end

def select_gift_item(trainer)
  rare_item_chances = 5 + (trainer.friendship/5).floor

  giving_rare_item = rand(100) < rare_item_chances

  typed_items = TRAINER_REMATCH_GIFTS[trainer.favorite_type]
  if giving_rare_item
    return typed_items[1].sample
  else
    items = typed_items[0] + TRAINER_REMATCH_GIFTS[:ANY]
    return items.sample
  end
end