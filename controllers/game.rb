before "/game" do
  return unless request.websocket?
end

get "/game" do
  request.websocket do |websocket|
    @websocket = websocket

    @websocket.onopen { new_player }

    @websocket.onmessage do |message|
      puts "session #{session[:value]} received #{message}"
      @response = parse_json(message)[:msg].to_i

      case @response
      when 0
        ready
      when -1
        leave if game_exist?(session[:value])
        replay
      when 1..25
        return unless game_exist?(session[:value])
        turn
      end
    end

    @websocket.onclose { quit }
  end
end

def new_player
  session[:value] = $matchmaker.process_player(@websocket)
  puts "ws open for session #{session[:value]}"
end

def ready
  process_zero_response(session[:value], @websocket)
end

def leave
  process_leaver_response(session[:value], @websocket)
end

def replay
  rematch(session[:value], @websocket)
end

def turn
  make_a_move(session[:value], @response)
  send_out_game_information(session[:value], @websocket)
end

def quit
  notify_opponent_of_leaver(session[:value])
  delete_player_upon_leaving(session[:value])
end