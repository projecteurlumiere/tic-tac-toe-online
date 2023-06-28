def parse_json(json)
  begin
    parsed_json = JSON.parse(json, symbolize_names: true)
  rescue JSON::ParserError
    puts 'invalid JSON'
    return
  end
  parsed_json
end

def notify_game_status(player_id, websocket, status)
  websocket.send JSON.generate(
    {
      found_game: status
    })
  access_player_hash(player_id)[:game_start_notified] = true
end

def send_out_game_information(websocket, player_id)
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
