def process_http_request(parameter = nil)
  puts "parameter is #{parameter}"
  @server_address = $settings_hash[:server_address]
  puts "BOARD PROCKED #{parameter}"
  if parameter == '3' || parameter == '5'
    @size = parameter.to_i
    @template = :board
  else
    @template = :entrance
  end

  erb :layout
end

def process_zero_response(player_id, websocket)
  puts "zero response PROCKED"
  if !game_exist?(player_id)
    p access_player_hash(player_id)[:current_game]
    notify_game_status(player_id, websocket, false)
  elsif game_exist?(player_id) && game_over?(player_id)
      rematch(player_id, websocket)
  elsif game_exist?(player_id)
    notify_both_game_status(player_id, websocket, true) if game_start_notified?(player_id) == false
    send_out_game_information(player_id, websocket)
  end
end

def process_leaver_response(player_id, websocket)
  notify_opponent_of_leaver(player_id)
  rematch(player_id, websocket)
end