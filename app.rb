# TODO: server doesn't send anything when game is created

require 'json'
require 'sinatra'
require 'sinatra-websocket'
require './tictactoe.rb'
require './matchmaker.rb'

matchmaker = Matchmaker.new

set :sockets, []
set :server, 'thin'

configure do
  enable :sessions
end

get '/' do
  if !request.websocket?
    puts "ws open"
    # if params['board'] == "3"
    #   # params[board] equals three. need to arrange for 5
      @template = :board
      erb :layout
    # else
    #   @template = :entrance
    #   erb :layout
    # end

  elsif request.websocket?

    request.websocket do |websocket|

      websocket.onopen do
        puts "ws open"
        settings.sockets << websocket # do i really need this? No, i don't
        player_id = matchmaker.process_new_player(websocket)
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

        puts response
        puts response[:msg]

        if response[:msg] == 0 # look for how to make symbols in js (instead of strings)
          if matchmaker.players_online[session[:value]][:current_game].nil?
            puts "condition procs"
            notify_game_not_found(websocket)
          elsif matchmaker.players_online[session[:value]]
            if game_over?
              matchmaker.delete_player(session[:value])
              session[:value] = matchmaker.process_new_player(websocket)
              return
            else
              send_out_game_information
            end
          end
        elsif response[:msg].to_i.between?(1,9) # look for how to make symbols in js (instead of strings)
          send_out_game_information
        end
      end

      websocket.onclose do |message|
        puts "ws closed"
        matchmaker.delete_player(session[:value])
        p matchmaker.players_queue
        matchmaker.players_queue.delete(session[:value])
        p matchmaker.players_queue
      end
      
      # websocket.onmessage do |msg|
      #   if JSON.parse(msg)["turn"] == "ready" && $player_queue.include?(@player_id)
      #     websocket.send "0"
      #   elsif msg == "ready"
      #     @current_game = $players_online[player_id][current_game][game]
      #     websocket.send get_game_information(@current_game)
      #   elsif JSON.parse(msg)[turn].between?(1, 9)
      #     websocket.send get_game_information(@current_game)
      #   end
      # end
      # websocket.onclose do


      #   settings.sockets.delete(websocket)
      #   # delete player from the list and from the queues.
      # end
    end
  end
end

def notify_game_not_found(websocket)
  websocket.send "haha!"
  websocket.send JSON.generate(
    {
      found_game: false
    })
end

def send_out_game_information
  json_message = JSON.generate(get_response_hash(session[:value]))
  websocket.send json_message
  opponent_socket = get_opponent_socket(session[:value])
  opponent_socket.send json_message
end

def get_response_hash(player_id)
  matchmaker.players_online[player_id][:current_game].get_response_hash(session[:value])
end

def get_opponent(player_id)
  matchmaker.players_online[matchmaker.players_online[player_id]][:opponent]
end

def get_opponent_socket(player_id)
  get_opponent(player_id)[:socket]
end

def game_over?
  if matchmaker.players_online[session[:value]][:current_game].get_response_hash(session[:value][:win])
    true
  else
    false
  end
end

def delete_match
  matchmaker.delete_player(get_opponent(session[:value]))
  matchmaker.delete_player(session[:value])
end

# ws.onmessage do |msg|
            #   EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
            # end
# end

# // To server:
# // msg: 0 or 1-9; integer 0 if ready, 1-9 if make a choice

# // From server:
# // found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
# // board: Array; 
# // turn: boolean; (true if turn is yours)
# // symbol: X or O; string (this is your symbol)
# // error: boolean;
# // win: boolean; (if none then undef)