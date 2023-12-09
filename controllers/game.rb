before "/game" do
  return unless request.websocket?

  @player_id = session[:value]
end

get "/game" do
  request.websocket do |websocket|
    @websocket = websocket

    @websocket.onopen { new_player }

    @websocket.onmessage do |message|
      puts "session #{@player_id} received #{message}"
      @response = parse_json(message)[:msg].to_i

      case @response
      when 0
        ready
      when -1
        leave if game_exist?(@player_id)
        replay
      when 1..25
        return unless game_exist?(@player_id)
        turn
      end
    end

    @websocket.onclose { quit }
  end
end

def new_player
  @player_id = $matchmaker.new_player(@websocket)
  puts "ws open for session #{@player_id}"
end

def ready
  puts "zero response PROCKED"

  if !game_exist?(@player_id)
    p access_player_hash(@player_id)[:current_game]
    notify_game_status(@player_id, @websocket, false)
  elsif game_exist?(@player_id) && game_over?(@player_id)
    rematch(@player_id, @websocket)
  elsif game_exist?(@player_id)
    notify_both_game_status(@player_id, @websocket, true) if game_start_notified?(@player_id) == false
    send_out_game_information(@player_id, @websocket)
  end

end

def leave
  notify_opponent_of_leaver(@player_id)
  rematch(@player_id, @websocket)
end

def replay
  rematch(@player_id, @websocket)
end

def turn
  make_a_move(@player_id, @response)
  send_out_game_information(@player_id, @websocket)
end

def quit
  notify_opponent_of_leaver(@player_id)
  delete_player_upon_leaving(@player_id)
end