def access_player_hash(player_id)
  $matchmaker.players_online[player_id]
end

def get_player_response_hash(player_id)
  access_player_hash(player_id)[:current_game].get_response_hash(player_id)
end

def get_opponent_id(player_id)
  access_player_hash(player_id)[:opponent]
end

def get_opponent_class(player_id)
  $matchmaker.players_online[access_player_hash(player_id)[:opponent]]
end

def get_opponent_socket(player_id)
  get_opponent_class(player_id)[:socket]
end

def game_over?(player_id)
  if get_player_response_hash(player_id).include?(:win)
    true
  else
    false
  end
end

def game_start_notified?(player_id)
  access_player_hash(player_id)[:game_start_notified]
end

def delete_player_upon_leaving(player_id)
  if access_player_hash(player_id)[:current_game]
    delete_current_game(player_id)
  elsif $matchmaker.players_queue.any?(player_id)
    delete_from_queue(player_id)
  end
  delete_player(player_id)
end

def delete_current_game(player_id)
  [get_opponent_id(player_id), player_id].each do |id|
    socket = access_player_hash(id)[:socket]
    delete_player(id)
    $matchmaker.add_player(id, socket)
  end
end

def delete_from_queue(player_id)
  $matchmaker.players_queue.delete(player_id)
end

def delete_player(player_id)
  $matchmaker.players_online[player_id] = nil
end

def rematch(player_id, websocket)
  delete_current_game(player_id) if game_exist?(player_id)
  $matchmaker.new_player(player_id, websocket)
end

def game_exist?(player_id)
  access_player_hash(player_id)[:current_game] ? true : false
end