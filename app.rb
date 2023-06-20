require 'sinatra'

$players_online = Hash.new
$player_queue = Array.new
$games = Hash.new
$total_games = 0

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
  $games[game_id] = {
    game: nil,
    player_one: player,
    player_two: $player_queue.shift,
    player_two_found: false
  }
  game_id
end

configure do
  enable :sessions
end

get '/' do
  session[:value] = rand(100000000000)
  puts session[:value].inspect
  erb :game
end

post '/' do
  player_id = session[:value]

  if params[:ready_for_game] == "true"


    if $players_online[player_id].nil?
      game_id = process_new_player(player_id)
      status 201
    elsif $player_queue.include?(player_id)
      status 202
    else $players_online[player_id]
      status 200
      current_game = $players_online[player_id][current_game]
      body current_game.to_s
    end

  # puts "players queue #{$player_queue}"
  # puts "players online #{$players_online}"
  # puts "games #{$games}"
  end
end