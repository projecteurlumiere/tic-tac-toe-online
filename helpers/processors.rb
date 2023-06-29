def process_http_request(parameter = nil)
  puts "parameter is #{parameter}"
  @server_address = "localhost:4567/"
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
  if access_player_hash(player_id)[:current_game].nil?
    p access_player_hash(player_id)[:current_game]
    notify_game_status(player_id, websocket, false)
  else
    if game_over?(player_id)
      process_rematch(player_id)
    else
      notify_both_game_status(player_id, websocket, true) if game_start_notified?(player_id) == false
      send_out_game_information(websocket, player_id)
    end
  end
end
