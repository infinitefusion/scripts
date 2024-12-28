class ClothesShopPresenter < PokemonMartScreen
  def pbChooseBuyItem

  end

  def initialize(scene, stock, adapter = nil, versions = false)
    super(scene, stock, adapter)
    @use_versions = versions
  end

  def putOnClothes(item)
    @adapter.putOnOutfit(item)
    @scene.pbEndBuyScene
  end

  def playerHatActionsMenu(item)
    if $Trainer.hat_color != 0
      choice = pbMessage("What would you like to do?", ["Wear", "Remove dye", "Cancel"])
      if choice == 0
        putOnClothes(item)
        $Trainer.hat_color = @adapter.get_dye_color(item)
        return
      elsif choice == 1
        if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
          $Trainer.hat_color = 0
        end
        return
      end
    else
      if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
        putOnClothes(item)
        return
      end
    end
  end

  #returns if should stay in the menu
  def playerClothesActionsMenu(item)
    if $Trainer.clothes_color != 0
      choice = pbMessage("What would you like to do?", ["Wear", "Remove dye", "Cancel"])
      if choice == 0
        putOnClothes(item)
        $Trainer.clothes_color = @adapter.get_dye_color(item)
        return false
      elsif choice == 1
        if pbConfirm(_INTL("Are you sure you want to remove the dye from the {1}?", item.name))
          $Trainer.clothes_color = 0
        end
        return true
      end
    else
      if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
        putOnClothes(item)
        return false
      end
    end
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item

      if !@adapter.isShop?
        if @adapter.is_a?(ClothesMartAdapter)
          stay_in_menu = playerClothesActionsMenu(item)
          next if stay_in_menu
        elsif @adapter.is_a?(HatsMartAdapter)
          stay_in_menu = playerHatActionsMenu(item)
          next if stay_in_menu
        else
          if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
            putOnClothes(item)
            return
          end
          next
        end
        next
      end
      itemname = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)
      if !price.is_a?(Integer)
        pbDisplayPaused(_INTL("You already own this item!"))
        if pbConfirm(_INTL("Would you like to put on the {1}?", item.name))
          @adapter.putOnOutfit(item)
        end
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end

      if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
                          itemname, price.to_s_formatted))
        next
      end
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      @adapter.setMoney(@adapter.getMoney - price)
      @stock.compact!
      pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
      @adapter.addItem(item)
      #break
    end
    @scene.pbEndBuyScene
  end

end