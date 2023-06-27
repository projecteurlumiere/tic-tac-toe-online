require 'sinatra'
require 'sinatra-websocket'

require 'json'
require 'require_all'

require_relative 'tictactoe'
require_relative 'matchmaker'
require_all 'helpers'

$matchmaker = Matchmaker.new

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
    puts "#received params are #{params} and borrd is #{params['board']}"
    process_http_request(params['board'])

  elsif request.websocket?
    request.websocket do |websocket|

      websocket.onopen do
        session[:value] = $matchmaker.process_player(websocket)
        puts "ws open for session #{session[:value]}"
      end

      websocket.onmessage do |message|
        puts "session #{session[:value]} received #{message}"
        response = parse_json(message)

        response[:msg] = response[:msg].to_i if response[:msg].to_i.between?(0, 25)

        if response[:msg].zero?
          process_zero_response(session[:value], websocket)
        elsif response[:msg].between?(1, 25) && access_player_hash(session[:value])[:current_game]
          make_a_move(session[:value], response[:msg])
          send_out_game_information(websocket, session[:value])
        end
      end

      websocket.onclose do |message|
        notify_opponent_of_leaver(session[:value])
        delete_player_upon_leaving(session[:value])
      end
    end
  end
end

# // To server:
# // msg: 0 or 1-25; integer 0 if ready, 1-25 if make a choice

# // emoji: emoji string to show

# // From server:
# // found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
# // board: Array; 
# // turn: boolean; (true if turn is yours)
# // symbol: X or O; string (this is your symbol)
# // error: boolean;
# // win: boolean; (if none then undef)
# // leaver: true (otherwise undefined)