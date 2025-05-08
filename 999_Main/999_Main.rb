class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def handleReplaceExistingSprites()
  spritesToReplaceList= $game_temp.unimportedSprites
  $game_temp.unimportedSprites=nil
  return if spritesToReplaceList.size==0
  commands = []
  #commands << "Pick which sprites to use as mains"
  commands << _INTL("Do not import the new sprites")
  commands << _INTL("Replace all the old sprites with the new ones")
  #commands << "Import all the new sprites as alts"

  message = _INTL("While importing custom sprites, the game has detected that {1} new custom sprite already has a version that exist in the game.", spritesToReplaceList.size)
  message = _INTL("While importing custom sprites, the game has detected that {1} new custom sprites already have versions that exist in the game.", spritesToReplaceList.size) if spritesToReplaceList.size > 1
  pbMessage(message)

  command = pbMessage(_INTL("What to do with the new sprites?"),commands,commands.size-1)
  case command
  when 0 #Do not import
    pbMessage(_INTL("You can manually sort the new sprites in the /indexed folder to choose which ones you want to keep."))
    pbMessage(_INTL("You can also delete the ones you don't want to replace the main sprites and restart the game."))
    pbMessage(_INTL("Keep in mind that the game will take longer to load until these sprites are imported/removed."))

    return
  when 1 #Replace olds
    spritesToReplaceList.each do |oldPath, newPath|
      File.rename(oldPath, newPath)
      $game_temp.nb_imported_sprites+=1
      echo "\nSorted " + oldPath + " into " + newPath
    end
    #when 2 #Keep olds (rename new as alts)
  end
end

def pbCallTitle
  #return Scene_DebugIntro.new if $DEBUG
  return Scene_Intro.new
end

def mainFunction
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def clearTempFolder()
  folder_path = Settings::DOWNLOADED_SPRITES_FOLDER
  Dir.foreach(folder_path) do |file|
    next if file == '.' or file == '..'
    file_path = File.join(folder_path, file)
    File.delete(file_path) if File.file?(file_path)
  end
end

def sortCustomBattlers()
  $game_temp.nb_imported_sprites=0
  echo "Sorting CustomBattlers files..."

  # pbMessage( "Warning: Sprites that are manually imported will not get updated when a new sprite pack releases. This means that if some contain errors, these will not get fixed for you. All of the sprites from the latest spritepack are already available in your game without the need to manually import anything.")
  # if !pbConfirmMessage( "Do you still wish to import the sprites that are in the \"Sprites to import\" folder")
  #   return
  # end

  alreadyExists = {}
  Dir.foreach(Settings::CUSTOM_SPRITES_TO_IMPORT_FOLDER) do |filename|
    next if filename == '.' or filename == '..'
    next if !filename.end_with?(".png")
    split_name = filename.split('.')

    headNum = split_name[0]
    oldPath = Settings::CUSTOM_SPRITES_TO_IMPORT_FOLDER + filename

    echoln split_name
    echoln split_name.length

    is_base_sprite = split_name.length ==2
    if is_base_sprite #fusion sprite
      newDir = Settings::CUSTOM_BASE_SPRITE_FOLDER
    else
      newDir = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + headNum.to_s
    end
    newPath = newDir + "/" + filename

    begin
      if File.file?(newPath)
        alreadyExists[oldPath] = newPath
        echo "\nFile " + newPath + " already exists... Skipping."

      else
          Dir.mkdir(newDir) if !Dir.exist?(newDir)
          File.rename(oldPath, newPath)
        $game_temp.nb_imported_sprites+=1
        echo "\nSorted " + filename + " into " + newPath
      end
    rescue
      echo "\nCould not sort "+ filename
    end
  end
  echo "\nFinished sorting"
  $game_temp.unimportedSprites=alreadyExists
end

# def playInViewPort(viewport)
#   @finished=false
#   @currentFrame = 1
#   @initialTime = Time.now
#   @timeElapsed = Time.now
#
#   pbBGMPlay(@bgm)
#   while (@currentFrame <= @maxFrame)# && !(@canStopEarly && Input::ACTION))
#     break if Input.trigger?(Input::C) && @canStopEarly
#     frame = sprintf(@framesPath, @currentFrame)
#     picture = Sprite.new(viewport)
#     picture.bitmap = pbBitmap(frame)
#     picture.visible=true
#     pbWait(Graphics.frame_rate / 20)
#     picture.dispose
#     @currentFrame += 1
#   end
#   @finished=true
#   pbBGMStop
# end


def showLoadingScreen
  loading_screen_folder = "Graphics/titles/loading_screens"
  available_loading_screens = Dir.glob("#{loading_screen_folder}/*.png")
  if available_loading_screens.length > 0
    selected_loading_screen = available_loading_screens.sample
  else
    selected_loading_screen = "Graphics/titles/default_loading_screen"
  end
  picture = Sprite.new(@viewport)
     picture.bitmap = pbBitmap(selected_loading_screen)
     picture.visible=true
     Graphics.update
     picture.dispose
end


def showLoadMovie
  path = "Graphics\\Pictures\\introMarill"
  loading_screen = Sprite.new(@viewport)
  loading_screen.bitmap = pbBitmap(path)
  loading_screen.visible=true
end

def mainFunctionDebug
  begin
    showLoadingScreen
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    #clearTempFolder()
    createCustomSpriteFolders()
    begin
      sortCustomBattlers()
    rescue
      echo "failed to sort custom battlers"
    end
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition(20)
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  if retval == 0   # failed
    loop do
      Graphics.update
    end
  elsif retval == 1   # ended successfully
    break
  end
end
