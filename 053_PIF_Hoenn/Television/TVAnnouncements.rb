class PokemonGlobalMetadata
  attr_accessor :tv_announcements
end

def getTVAnnouncementsHash #Keep in the function
  return {
    :hidden_ability => _INTL("This is a special bulletin for all Pokémon Trainers!\nPokémon boasting their hidden abilities have been spotted around \\C[1]{1}\\C[0]! Make sure to make your way over there for rare Pokémon before they're gone!\nThis concludes our special bulletin.", getCurrentHiddenAbilityMapName),
    :petalburg_contest => _INTL("Attention all berry enthusiasts! The Petalburg Berry Contest is now about to begin!\nWe'll be covering the event live in Petalburg Town, so make sure to tune for this special broadcast!")
  }
end

def addTVAnnouncement(announcementId)
  $PokemonGlobal.tv_announcements = [] unless $PokemonGlobal.tv_announcements
  $PokemonGlobal.tv_announcements << announcementId
end

def removeTVAnnouncement(announcement_id)
  if $PokemonGlobal.tv_announcements.include?(announcement_id)
    $PokemonGlobal.tv_announcements.delete(announcement_id)
  end
end

def isTVannouncement?
  return $PokemonGlobal.tv_announcements && $PokemonGlobal.tv_announcements.length > 0
end


def showTVannouncement
  if $PokemonGlobal.tv_announcements && $PokemonGlobal.tv_announcements.length >= 1
    announcement_id = $PokemonGlobal.tv_announcements.first
    raw_message = getTVAnnouncementsHash[announcement_id]
    if raw_message
      pbMEPlay("spotted_interviewer")

      messages =  raw_message.split("\n")
      messages.each do |line|
        pbMessage(line)
      end
      Audio.me_stop
    end
    removeTVAnnouncement(announcement_id)
  else
    showTVText
  end
end


def replaceAnnouncementKeywords()

end
