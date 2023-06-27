def notify_game_status(player_id, websocket, status)
  websocket.send JSON.generate(
    {
      found_game: status
    })
  access_player_hash(player_id)[:game_start_notified]
end

def send_out_game_information(websocket, player_id)
  json_message = JSON.generate(get_players_response_hash(player_id))
  websocket.send json_message
  get_opponent_socket(session[:value]).send json_message
end

def get_players_response_hash(player_id)
  access_player_hash(player_id)[:current_game].get_response_hash(player_id)
end

def get_opponent(player_id)
  $matchmaker.players_online[access_player_hash(player_id)[:opponent]]
end

def get_opponent_socket(player_id)
  get_opponent(player_id)[:socket]
end

def game_over?(player_id)
  p get_players_response_hash(player_id)
  if get_players_response_hash(player_id).include?(:win)
    true
  else
    false
  end
end

# def delete_match
#   $matchmaker.delete_player(get_opponent(session[:value]))
#   $matchmaker.delete_player(session[:value])
# end

def make_a_move(player_id, cell_number)
  access_player_hash(player_id)[:current_player_class].play(cell_number)
end

def game_start_notified?(player_id)
  access_player_hash(player_id)[:game_start_notified]
end

def access_player_hash(player_id)
  $matchmaker.players_online[player_id]
end