def access_player_hash(player_id)
  $matchmaker.players_online[player_id]
end

def get_player_response_hash(player_id)
  access_player_hash(player_id)[:current_game].get_response_hash(player_id)
end

def get_opponent(player_id)
  $matchmaker.players_online[access_player_hash(player_id)[:opponent]]
end

def get_opponent_socket(player_id)
  get_opponent(player_id)[:socket]
end

def game_over?(player_id)
  p get_player_response_hash(player_id)
  if get_player_response_hash(player_id).include?(:win)
    true
  else
    false
  end
end

def game_start_notified?(player_id)
  access_player_hash(player_id)[:game_start_notified]
end

# def delete_player
 
# end