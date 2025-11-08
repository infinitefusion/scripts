def berryContest(map_id,plots_event_ids=[])
  total_yield = 0
  plots_event_ids.each do |event_id|
    berryData = $PokemonGlobal.eventvars[[map_id, event_id]]
    if berryData
      berry_type = berryData[1]
      berry_yield = calculateBerryYield(berryData)
      total_yield += berry_yield
    end
  end
  return total_yield
end

def calculateBerryYield(berryData)
  berryvalues = GameData::BerryPlant.get(berryData[1])
  berrycount = [berryvalues.maximum_yield - berryData[6], berryvalues.minimum_yield].max
  return berrycount
end