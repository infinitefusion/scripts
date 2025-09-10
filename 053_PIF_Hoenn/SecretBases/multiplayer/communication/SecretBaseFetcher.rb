
#todo: limit of 10 at once

#todo: append new friends at the end of the list instead of overwriting everything

#todo: if the friend's id is already in there, update (overwrite) it
#
class SecretBaseFetcher
  SECRETBASE_DOWNLOAD_URL = "https://secretbase-download.pkmninfinitefusion.workers.dev"
  FRIEND_BASES_FILE = "Data/bases/friend_bases.json"

    def import_friend_base(friend_player_id)
      base_json = fetch_base(friend_player_id)
      if base_json
        save_friend_base(base_json)
      else
        pbMessage("The game couldn't find your friend's base. Make sure that they published it and that you wrote their trainer ID correctly.")
        raise "Secret Base does not exist"
      end
    end

  # Fetch a secret base by playerID
  def fetch_base(player_id)
      url = "#{SECRETBASE_DOWNLOAD_URL}/get-base?playerID=#{player_id}"

      begin
        response = HTTPLite.get(url)
        if response[:status] == 200
          echoln "[SecretBase] Downloaded base for #{player_id}"
          base_json = JSON.parse(response[:body])
          return base_json
        else
          echoln "[SecretBase] Failed with status #{response[:status]} for #{player_id}"
          return nil
        end
      rescue MKXPError => e
        echoln "[SecretBase] MKXPError: #{e.message}"
        return nil
      rescue Exception => e
        echoln "[SecretBase] Error: #{e.message}"
        return nil
      end
    end

  def save_friend_base(new_base)
    ensure_folder_exists(File.dirname(FRIEND_BASES_FILE))

    bases = []

    if File.exist?(FRIEND_BASES_FILE)
      begin
        file_content = File.read(FRIEND_BASES_FILE).strip
        if file_content.empty?
          bases = []
        else
          bases = JSON.parse(file_content)
          # ensure it's an array
          bases = [] unless bases.is_a?(Array)
        end
      rescue Exception => e
        echoln "[SecretBase] Error reading existing file: #{e.message}"
        bases = []
      end
    end

    echoln "Existing bases: #{bases}"
    echoln "New base: #{new_base}"

    # Append new base
    bases << new_base

    # Write back
    File.open(FRIEND_BASES_FILE, "w") do |file|
      file.write(JSON.generate(bases))
    end
    echoln "[SecretBase] Saved base to #{FRIEND_BASES_FILE}"
  end


end
