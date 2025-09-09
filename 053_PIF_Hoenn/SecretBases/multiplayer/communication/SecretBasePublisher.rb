class SecretBasePublisher
  def initialize()
    @player_id =  $Trainer.id
  end

  def register
    begin
      payload = { playerID: @player_id }
      url = "#{Settings::SECRETBASE_SERVER_URL}register"
      response = pbPostToString(url,payload)
      echoln response
      json = JSON.parse(response) rescue {}
      @secret_uuid = json["secretUUID"]
      echoln @secret_uuid
    rescue Exception => e
      echoln e
      pbMessage("There was an error connecting to the server.")
    end

  end

  def upload_base(base_json)
    payload = {
      action: "upload-base",
      playerID: @player_id,
      secretUUID: @secret_uuid,
      baseJSON: base_json
    }
    response = post_json(payload)
    echoln response

    json = JSON.parse(response) rescue {}
    json["success"] == true
  end

  private

end