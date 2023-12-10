class Matchmaker
  attr_accessor :players_online, :players_queue

  def initialize
  @players_online = Hash.new

  # {
  #   player_id_n: {
    #   socket:
    #   current_game: [null if none found]
    #   current_player_class:
    #   opponent: [null if none]
    #   game_start_notified: false/true
  #   }

  @players_queue = Array.new

  # [array of those who wait for a game]

  @total_games = 0
  @total_players = 0
  end

  def new_player(player_id = nil, socket)
    if player_id.nil?
      player_id = assign_player_id
      add_player(player_id, socket)
    end

    if @players_queue.empty?
      @players_queue << player_id
    elsif @players_queue.none?(player_id)
      create_game(player_id)
    end
    puts "#{player_id} is processed"
    player_id
  end

  def add_player(player_id, socket)
    @players_online[player_id] = {
      socket: socket
    }
  end

  private

  def create_game(player_one_id)
    player_two_id = @players_queue.shift
    game = Game.new(player_one_id, player_two_id)

    db_update_player_id(player_one_id, player_two_id, game)
    db_update_player_id(player_two_id, player_one_id, game)
    puts "game is created"
  end

  def assign_player_id
    @total_players += 1
    player_id = "#{@total_players}".to_sym
  end

  def db_update_player_id(player_id, opponent_id, game)
    puts "db update proced"
    @players_online[player_id].merge!(
      {
      current_game: game,
      current_player_class: game.get_player_class(player_id),
      game_start_notified: false,
      opponent: opponent_id
      }
    )
  end
end
