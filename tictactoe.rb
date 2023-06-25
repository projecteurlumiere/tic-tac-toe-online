SYMBOLS = ["X", "O"]

class Game
  attr_accessor :board, :player_one, :player_two 

  def initialize(player_one_id, player_two_id)
    @size = 3
    @rows = @size
    @columns = @size
    @maxturns = @size**2
    @player_one = Player.new(self, player_one_id, SYMBOLS.sample)
    puts "\nMoving to next player\n"
    @player_two = Player.new(self, player_two_id, get_opposite_symbol)
    check_symbols
    @change_error = false
    generate_game
  end

  def get_response_hash(player_id)
    if player_id == @player_one.id
      player_id = @player_one
    elsif player_id == @player_two.id
      player_id = @player_two
    else 
      return
    end
  
    info = {
      found_game: true,
      board: @board,
      turn: turn,
      error: @change_error,
      symbol: player_id.symbol
    }

    if win.nil?
      return info
    elsif win == player_id.symbol
      info.merge!({
        win: true
      })
    elsif win != player_id.symbol
      info.merge!({
        win: false
      })
    end
    info
  end

  def get_player_class(player_id)
    if player_id == @player_one
      @player_one
    elsif player_id == @player_two
      @player_two
    end
  end

  def get_opponent(player_id)
    if player_id == @player_one
      @player_two.id
    elsif player_id == @player_two
      @player_one.id
    end
  end


  def display
    p '-------------'
    i = 1
    @rows.times do
      p @board[i]
      i += 1
    end
    p '-------------'
  end

  def error?
    @change_error
  end

  def generate_game
    @turn = 0
    @x_wins = false
    @o_wins = false
    @board = Hash.new(0)
    generate_board
    allow_first_turn
  end

  def change_board(number, symbol)
    if legal_number?(number)
      get_coordinates(number, symbol)
      if legal_symbol?(symbol)
        process_turn(symbol)
        set_legality(symbol)
        @turn += 1
        @change_error = false
      else
        puts 'ERROR: ILLEGAL SYMBOL'
        @change_error = true
      end
    else
      puts 'ERROR: ILLEGAL NUMBER'
      @change_error = true
    end
    display
    get_winner
    if gameover?
      puts "\nGAME OVER\n"
    end
  end

  def legal_symbol?(symbol)
    if @board[@row][@column] == 'X' || @board[@row][@column] == 'O'
      false
    elsif symbol == 'X' && @x_is_legal == true
      true
    elsif symbol == 'O' && @o_is_legal == true
      true
    else
      false
    end
  end

  def legal_number?(number)
    if (1..(@columns * @rows)).to_a.include?(number)
      true
    else
      false
    end
  end

  def gameover?
    if @x_wins == true || @o_wins == true || @turn >= @maxturns
      true
    else
      false
    end
  end

  def turn
    "X" if @x_is_legal == true
    "O" if @o_is_legal == true
  end

  def win
    "X" if @x_wins
    "O" if @o_wins
  end

  private

  def get_game_information
    {
      board: @board,
      turn: turn,
      error: @change_error,
      win: win
    }
  end

  def get_game_information_full
    get_game_information.merge({
      player_one_id: @player_one.id,
      player_one_symbol: @player_one.symbol,
      player_two_id: @player_two.id,
      player_two_symbol: @player_two.symbol
      })
  end

  def get_opposite_symbol
    if @player_one.symbol == 'X'
      'O'
    else
      'X'
    end
  end

  def check_symbols
    while @player_one.get_symbol == @player_two.get_symbol
      puts "\nWell, you two can't play with the same symbols. Choose again\n\nFirst player, come back"
      @player_one = Player.new(self)

      puts "\nmoving to next player\n"
      @player_two = Player.new(self)
    end
  end

  def game_loop
    loop do
      puts "\nSo the game shall begin!\n"
      display
    
      while gameover? == false
        puts "\nFirst player, your turn. Choose number\n"
        @player_one.play(gets.chomp.to_i)
        while error?
          puts 'WRONG NUMBER! COME AGAIN'
          @player_one.play(gets.chomp.to_i)
        end
    
        break if gameover? != false
    
        puts "\nSecond player, your turn. Choose number\n"
        @player_two.play(gets.chomp.to_i)
        while error?
          puts 'WRONG NUMBER! COME AGAIN'
          @player_two.play(gets.chomp.to_i)
        end
      end
    
      puts "\nAnother one? Yes or No\n"
      @response = gets.chomp.upcase
      until @response == 'YES' || @response == 'NO'
        puts 'YES or NO'
        @response = gets.chomp.upcase
      end
    
      generate_game if @response == 'YES'
    
      break if @response == 'NO'
    end
    
    puts "\nbye!\n"
  end

  def choose_size
    puts "Choose board's size (3 or 5)"
    board_size = gets.chomp.to_i
    if board_size != 5 && board_size != 3
      puts 'WRONG! COME AGAIN (3 or 5)'
      choose_size
    end
    board_size
  end

  def generate_board
    i = 1
    @rows.times do
      array = ((((@columns * @rows) / @rows * i) - @columns + 1)..(@columns * @rows) / @rows * i).to_a
      array = array.map do |number|
        number.to_s
      end
      @board[i] = array
      i += 1
    end
  end

  def allow_first_turn
    if rand(0..1).zero?
      @x_is_legal = true
      @o_is_legal = false
    else
      @x_is_legal = false
      @o_is_legal = true
    end
  end

  def get_coordinates(number, symbol)
    @row = (number / @columns)
    if number % @columns != 0
      @row += 1
    end
    @column = ((@columns * ((number.to_f / @columns) - (@row - 1))) - 1).round(0)
  end

  def process_turn(symbol)
    @board[@row][@column] = symbol
  end

  def set_legality(symbol)
    if symbol == 'X'
      @x_is_legal = false
      @o_is_legal = true 
    elsif symbol == 'O'
      @x_is_legal = true
      @o_is_legal = false 
    end
  end

  def get_winner
    @x_wins = false
    @o_wins = false
    check_horizontal
    check_diagonal(true)
    check_diagonal(false)
    check_vertical
    if @x_wins == true
      puts 'X won'
    elsif @o_wins == true
      puts 'O won'
    elsif @x_wins == false && @o_wins == false && gameover? == true
      puts 'NO ONE won'
    end
  end

  def check_horizontal
    i = 1
    @rows.times do 
      if @board[i] == ['X', 'X', 'X']
        @x_wins = true
        break
      elsif @board[i] == ['O', 'O', 'O']
        @o_wins = true
        break
      else
        i += 1
      end
    end
  end

  def check_diagonal(from_left)
    i = 1
    @horizontal_array = Array.new(0)
    @columns.times do
      if from_left == true
        @horizontal_array << @board[i][(i - 1)]
      elsif from_left == false
        @horizontal_array << @board[i][(@columns - i)]
      end
      i += 1
    end
    if @horizontal_array == ['X', 'X', 'X'] 
      @x_wins = true
    elsif @horizontal_array == ['O', 'O', 'O']
      @o_wins = true
    end
  end

  def check_vertical
    c = 0
    @columns.times do
      r = 1
      @vertical_array = Array.new(0)
      @rows.times do
        @vertical_array << @board[r][c]
        r += 1
      end
      if @vertical_array == ['X', 'X', 'X'] 
        @x_wins = true
      elsif @vertical_array == ['O', 'O', 'O']
        @o_wins = true
      end
      c += 1
    end
  end
end

class Player
  attr_accessor :symbol, :id, :symbol

  def initialize(board_name, id, symbol) 
    @board_name = board_name
    puts "\nWhat's your name?\n"
    @id = id
    @symbol = symbol
  end

  def play(number)
    @board_name.change_board(number, @symbol)
  end

  def get_symbol
    @symbol
  end

  private

  def choose_symbol
    puts "\n#{@name}, choose X or O?\n"
    @symbol = gets.chomp.upcase.to_s
    if @symbol != 'X' && @symbol != 'O'
      puts 'WRONG! X or O?'
      choose_symbol
    else
      @symbol
    end
  end
end