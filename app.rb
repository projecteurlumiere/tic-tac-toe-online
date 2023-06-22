require 'sinatra'
require 'sinatra-websocket'
require './tictactoe.rb'
require 'json'

include TicTacToe

$players_online = Hash.new
$player_queue = Array.new
$games = Hash.new
$total_games = 0
set :sockets, []
set :server, 'thin'

def assign_unique_id
  session[:value] = rand(100000000000)
  puts session[:value].inspect
end

def process_new_player(player)
  if $player_queue.empty?
    $player_queue << player
    $players_online[player] = {}
  else
    game_id = create_game(player)
    $players_online[player] = {
      current_game: game_id
    }
    game_id
  end
end

def create_game(player)
  $total_games += 1
  game_id = $total_games
  player_two = $player_queue.shift
  game = Game.new(player, player_two) # randomize first turn & add them to hash
  $games[game_id] = {
    game: game,
    player_one: player,
    player_two: player_two
  }
  puts games[game_id] # will it return hash or what?
  game_id
end

def get_game_information(game)
  {
    current_board: game.board,
    turn: game.turn,
  }.to_json
end

configure do
  enable :sessions
end

get '/' do
  if !request.websocket?
    assign_unique_id
    erb :game
  elsif request.websocket?
    request.websocket do |ws|
      ws.onopen do
        puts "connection established"
        settings.sockets << ws

        @player_id = session[:value]
        @game_id = process_new_player(@player_id)

      end
      ws.onmessage do |msg|
        if JSON.parse(msg)["turn"] == "ready" && $player_queue.include?(@player_id)
          ws.send "0"
        elsif msg == "ready"
          @current_game = $players_online[player_id][current_game][game]
          ws.send get_game_information(@current_game)
        elsif JSON.parse(msg)[turn].between?(1, 9)
          ws.send get_game_information(@current_game)
        end
      end
      ws.onclose do


        settings.sockets.delete(ws)
        # delete player from the list and from the queues.
      end
    end
  end
end

# post '/' do
#   player_id = session[:value]

#   if params[:ready_for_game] == "true"


#     if $players_online[player_id].nil?
#       game_id = process_new_player(player_id)
#       status 201
#     elsif $player_queue.include?(player_id)
#       status 202
#     else $players_online[player_id]
#       status 200
#       current_game = $players_online[player_id][current_game]
#       body current_game.to_s
#     end

#   # puts "players queue #{$player_queue}"
#   # puts "players online #{$players_online}"
#   # puts "games #{$games}"
#   end
# end