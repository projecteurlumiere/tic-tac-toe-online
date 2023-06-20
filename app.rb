require 'sinatra'

$player_queue = []
$games = Hash.new(0)
$total_games = 0

def process_new_player(player)
  unless $player_queue.empty?
    game = {
      game: nil,
      player_one: player,
      player_two: $player_queue.shift,
    }
    $total_games += 1
    game_id = $total_games
    $games[game_id] = game
    return game_id
  else
    player_queue << player
  end
end


configure do
  enable :sessions
end

get '/' do
  erb :game
end

post '/' do
  if params[:ready_for_game] = true
    unless (game_id = process_new_player(session[:value])).nil?
      return game_id
    end
  end
end