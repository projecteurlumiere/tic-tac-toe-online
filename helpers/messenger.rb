def parse_json(json)
  begin
    parsed_json = JSON.parse(json, symbolize_names: true)
  rescue JSON::ParserError
    puts 'invalid JSON'
    return
  end
  parsed_json
end

def send_emote(player_id, websocket, emotion_id) # -2 = happy; -3 = scared; -4 = crying
  hash = {
    emotion: emotion_id
  }

  # websocket.send JSON.generate(hash)
  begin
    get_opponent_socket(player_id).send JSON.generate(hash)
  rescue NoMethodError
    puts "no opponent to send to"
  end
end

def notify_game_status(player_id, websocket, status)
  websocket.send JSON.generate(
    {
      found_game: status
    })
  access_player_hash(player_id)[:game_start_notified] = true
end

def notify_both_game_status(player_id, websocket, status)
  notify_game_status(player_id, websocket, status)
  notify_game_status(get_opponent_id(player_id), get_opponent_socket(player_id), status)
end

def send_out_game_information(player_id, websocket)
  websocket.send JSON.generate(get_player_response_hash(player_id))
  get_opponent_socket(player_id).send JSON.generate(get_player_response_hash(get_opponent_id(player_id)))
end

def notify_opponent_of_leaver(player_id)
  if access_player_hash(player_id)[:current_game]
    get_opponent_socket(player_id).send JSON.generate(
      {
        leaver: true
      }
    )
  end
end
