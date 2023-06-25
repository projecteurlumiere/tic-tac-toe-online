require 'json'
require 'sinatra'
require 'sinatra-websocket'
require_relative 'tictactoe'
require_relative 'matchmaker'
require_relative 'misc'

$matchmaker = Matchmaker.new

set :sockets, []
set :server, 'thin'
set :static_cache_control, [:no_cache]

configure do
  enable :sessions
end

before do
  cache_control :no_cache
end

get '/' do
  if !request.websocket?
    puts "ws open"
    if params['board'] == "3"
      puts "board condition procs"
      # params[board] equals three. need to arrange for 5
      @template = :board
      erb :layout
    else
      @template = :entrance
      erb :layout
    end

  elsif request.websocket?

    request.websocket do |websocket|

      websocket.onopen do
        puts "ws open"
        settings.sockets << websocket # do i really need this? No, i don't
        player_id = $matchmaker.process_new_player(websocket)
        puts "#PLAYER ID IN WEBSOCKET IS: #{player_id}"
        session[:value] = player_id
        puts "SESSION VALUE: #{session[:value]}"
      end

      websocket.onmessage do |message|
        puts "ws received #{message}"
        begin
          response = JSON.parse(message, symbolize_names: true)
        rescue JSON::ParserError
          puts "invalid JSON"
          break # will it break the entire block?
        end

        response[:msg] = response[:msg].to_i

        puts response
        puts response[:msg]

        if response[:msg].to_i == 0 # look for how to make symbols in js (instead of strings)

          puts "first condition procs"

          if $matchmaker.players_online[session[:value]][:current_game].nil?
            puts "condition procs"
            notify_game_status(session[:value], websocket, false)

          elsif $matchmaker.players_online[session[:value]]

            if game_start_notified?(session[:value]) == false
              notify_game_status(session[:value], websocket, true)
              send_out_game_information(websocket)

            elsif game_over?(session[:value])
              $matchmaker.delete_player(session[:value])
              session[:value] = $matchmaker.process_new_player(websocket)
              return

            else
              send_out_game_information(websocket)

            end
          end
        elsif response[:msg].to_i.between?(1, 9) # look for how to make symbols in js (instead of strings)
          make_a_move(session[:value], response[:msg])
          send_out_game_information(websocket)

        end
      end

      websocket.onclose do |message|
        puts "ws closed"

        $matchmaker.delete_player(session[:value])
        p $matchmaker.players_queue

        $matchmaker.players_queue.delete(session[:value])
        p $matchmaker.players_queue
      end
      
    end
  end
end

# // To server:
# // msg: 0 or 1-9; integer 0 if ready, 1-9 if make a choice

# // From server:
# // found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
# // board: Array; 
# // turn: boolean; (true if turn is yours)
# // symbol: X or O; string (this is your symbol)
# // error: boolean;
# // win: boolean; (if none then undef)