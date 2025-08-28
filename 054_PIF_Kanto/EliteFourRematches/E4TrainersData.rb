# frozen_string_literal: true

#Levels relative to 50 (actual level is adjusted dynamically depending on the type of rematch)


E4_POKEMON_POOL = {
  :ELITEFOUR_Lorelei => [
    #original league team
    {:species => [:MAGMORTAR,:DEWGONG],   :level => 4, :ability => :FLAMEBODY,  :moves => [:BUBBLEBEAM,:FLAMETHROWER,:HAIL,:PROTECT],         :item => :NEVERMELTICE , :tier => 1},   # Magmortar / Dewgong
    {:species => [:MAMOSWINE,:SLOWBRO],   :level => 4, :ability => :OBLIVIOUS,  :moves => [:HAIL,:SLACKOFF,:TAKEDOWN,:ICEFANG],               :item => :NEVERMELTICE, :tier => 1},   # Mamoswine / Slowbro
    {:species => [:TENTACRUEL,:CLOYSTER], :level => 3, :ability => :SHELLARMOR, :moves => [:SPIKES,:STEALTHROCK,:WATERPULSE,:ICICLECRASH],    :item => :NEVERMELTICE, :tier => 1},   # Tentacruel / Cloyster
    {:species => [:JYNX,:TANGROWTH],      :level => 7, :ability => :OBLIVIOUS,  :moves => [:LEECHSEED,:DRAININGKISS,:SLEEPPOWDER,:ICEPUNCH],  :item => :NEVERMELTICE, :tier => 1},   # Jynx / Tangrowth
    {:species => [:WEAVILE,:LAPRAS],      :level => 7, :ability => :PRESSURE,   :moves => [:PERISHSONG,:NIGHTSLASH,:SURF,:EMBARGO],           :item => :NEVERMELTICE, :tier => 1},   # Weavile / Lapras
    #reserve

  ],

  :ELITEFOUR_Bruno => [
    #original league team
    {:species => [:MACHAMP,:ELECTIVIRE],  :level => 3, :ability => :NOGUARD,    :moves => [:THUNDERPUNCH,:CROSSCHOP,:DISCHARGE,:FOCUSENERGY], :item => :BLACKBELT, :tier => 1}, # Machamp / Electivire
    {:species => [:SCIZOR,:HERACROSS],    :level => 7, :ability => :SWARM,      :moves => [:XSCISSOR,:SWORDSDANCE,:CLOSECOMBAT,:AGILITY],     :item => :BLACKBELT, :tier => 1}, # Scizor / Heracross
    {:species => [:MAROWAK,:HITMONCHAN],  :level => 4, :ability => :IRONFIST,   :moves => [:DYNAMICPUNCH,:BONEMERANG,:DOUBLETEAM,:COUNTER],  :item => :BLACKBELT, :tier => 1}, # Marowak / Hitmonchan
    {:species => [:STEELIX,:MACHAMP],     :level => 3, :ability => :STURDY,     :moves => [:SANDSTORM,:IRONTAIL,:SUBMISSION,:CRUNCH],        :item => :BLACKBELT, :tier => 1}, # Steelix / Machamp
    {:species => [:MAGNEZONE,:ONIX],      :level => 7, :ability => :MAGNETPULL, :moves => [:ZAPCANNON,:MAGNETRISE,:LOCKON,:IRONTAIL],        :item => :BLACKBELT, :tier => 1}, # Magnezone / Onix
    #reserve

  ],

  :ELITEFOUR_Agatha => [
    #original league team
    {:species => [:MISMAGIUS,:CROBAT],    :level => 7, :ability => :LEVITATE,   :moves => [:WINGATTACK,:SHADOWBALL,:CONFUSERAY,:MEANLOOK],   :item => :SPELLTAG, :tier => 1}, # Mismagius / Crobat
    {:species => [:GENGAR,:HOUNDOOM],     :level => 5, :ability => :EARLYBIRD,  :moves => [:INFERNO,:SPITE,:DESTINYBOND,:SHADOWBALL],        :item => :SPELLTAG, :tier => 1}, # Gengar / Houndoom
    {:species => [:UMBREON,:HAUNTER],     :level => 5, :ability => :LEVITATE,   :moves => [:GUARDSWAP,:DARKPULSE,:MOONLIGHT,:NIGHTSHADE],    :item => :SPELLTAG, :tier => 1}, # Umbreon / Haunter
    {:species => [:SNORLAX,:GENGAR],      :level => 8, :ability => :LEVITATE,   :moves => [:REST,:CURSE,:BODYSLAM,:SHADOWPUNCH],             :item => :SPELLTAG, :tier => 1}, # Snorlax / Gengar
    {:species => [:WOBBUFFET,:GENGAR],    :level => 5, :ability => :SHADOWTAG,  :moves => [:DESTINYBOND,:COUNTER,:MIRRORCOAT,:CURSE],        :item => :SPELLTAG, :tier => 1}, # Wobbuffet / Gengar
    #reserve

  ],

  :ELITEFOUR_Lance => [
    #original league team
    {:species => [:DRAGONAIR,:GYARADOS],  :level => 5, :ability => :SHEDSKIN,   :moves => [:OUTRAGE,:THUNDERWAVE,:HYDROPUMP,:RAINDANCE],     :item => :DRAGONFANG, :tier => 1}, # Dragonair / Gyarados
    {:species => [:PORYGON2,:KINGDRA],    :level => 4, :ability => :TRACE,      :moves => [:TRIATTACK,:DRAGONDANCE,:DRAGONPULSE,:RECOVER],   :item => :DRAGONFANG, :tier => 1}, # Porygon2 / Kingdra
    {:species => [:TYRANITAR,:AERODACTYL],:level => 9, :ability => :PRESSURE,   :moves => [:BRAVEBIRD,:HEADSMASH,:AGILITY,:DRAGONRUSH],      :item => :DRAGONFANG, :tier => 1}, # Tyranitar / Aerodactyl
    {:species => [:TYPHLOSION,:DRAGONAIR],:level => 7, :ability => :BLAZE,      :moves => [:FIREBLAST,:DRAGONTAIL,:DRAGONDANCE,:WILLOWISP],  :item => :DRAGONFANG, :tier => 1}, # Typhlosion / Dragonair
    {:species => [:TOGEKISS,:DRAGONITE],  :level => 8, :ability => :HUSTLE,     :moves => [:MOONBLAST,:OUTRAGE,:ANCIENTPOWER,:AIRSLASH],     :item => :DRAGONFANG, :tier => 1}, # Togekiss / Dragonite
    #reserve

  ],

  #Starter is always added to the team, no matter what
  :CHAMPION => [
    #original league team
    {:species => [:MAROWAK,:PIDGEOT],      :level => 9, :ability => :SAMPLE,     :moves => [:EARTHQUAKE,:WINGATTACK,:DOUBLETEAM,:SWORDSDANCE],:item => :LAXINCENSE, :tier => 1}, # Marowak / Pidgeot
    {:species => [:TAUROS,:EXEGGUTOR],     :level => 9, :ability => :SAMPLE,     :moves => [:ZENHEADBUTT,:GIGAIMPACT,:SCARYFACE,:SWAGGER],    :item => :KINGSROCK, :tier => 1}, # Tauros / Exeggutor
    {:species => [:RHYPERIOR,:MAGMORTAR],     :level => 10,:ability => :SAMPLE,     :moves => [:FIREBLAST,:DRILLRUN,:WILLOWISP,:STONEEDGE],      :item => :ABSORBBULB, :tier => 1}, # Rhydon / Magmortar
    {:species => [:ELECTABUZZ,:GYARADOS],  :level => 11,:ability => :SAMPLE,     :moves => [:RAINDANCE,:THUNDERPUNCH,:WATERFALL,:DRAGONDANCE],:item => :DAMPROCK, :tier => 1}, # Electabuzz / Gyarados
    {:species => [:STARMIE,:ALAKAZAM],     :level => 8, :ability => :SAMPLE,     :moves => [:PSYCHIC,:REFLECT,:SURF,:COSMICPOWER],            :item => :WISEGLASSES, :tier => 1}, # Starmie / Alakazam
    #original mt. silver team
    {:species => [:ARCANINE,:TYRANITAR],   :level => 9, :ability => :SAMPLE, :moves => [:THRASH,:FIREFANG,:CRUNCH,:ROAR],                 :item => :SMOOTHROCK, :tier => 3}, # Arcanine / Tyranitar
    {:species => [:AEGISLASH,:AERODACTYL], :level => 10, :ability => :SAMPLE, :moves => [:STEELWING,:DRAGONDANCE,:TAILWIND,:KINGSSHIELD],:item => :METALCOAT, :tier => 3}, # Aegislash / Aerodactyl
    {:species => [:MISMAGIUS,:ALAKAZAM],   :level => 9, :ability => :SAMPLE, :moves => [:CALMMIND,:MYSTICALFIRE,:TRICKROOM,:PSYCHIC],   :item => :WISEGLASSES, :tier => 3}, # Mismagius / Alakazam
    {:species => [:CROBAT,:PIDGEOT],       :level => 11, :ability => :SAMPLE, :moves => [:WHIRLWIND,:CROSSPOISON,:UTURN,:AIRSLASH],      :item => :RAZORFANG, :tier => 3}, # Crobat / Pidgeot
    #reserve

  ],
}






