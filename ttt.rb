class Invalid < StandardError
  def message
    "Not a valid response! Please try again..."
  end
end

class Quit < StandardError; end

class Taken < StandardError
  def message
    "Already taken!"
  end
end

class Game
  require "rainbow"

  def initialize
    puts "\e[H\e[2J"
    choose_players
    puts "\e[H\e[2J"
    make_board
    show_board(@board)
    puts "Enter (q) at any time to quit."
    player1_turn
  end



####### Choosing the players

  def choose_players
    begin
      puts "Choose how many players, (1) or (2)."
      players = gets.chomp

      raise Quit if players == "q"

      players = players.to_i

      raise Invalid unless (1..2).include?(players)

    rescue Quit
      exit
    rescue Invalid => e
      puts e.message
    retry
    end

    if players == 1
      puts "What's your name?"
      @player1 = gets.chomp
      @player2 = "Computer"
      difficulty
    elsif players == 2
      puts "Player 1, what's your name?"
      @player1 =  gets.chomp
      puts "Player 2, what's your name?"
      @player2 =  gets.chomp
    end
  end


####### Setting difficulty

  def difficulty
    begin
      puts "Select difficulty level, (1) for hard, (2) for medium, and (3) for easy."
      @difficulty = gets.chomp

      raise Quit if @difficulty == "q"

      @difficulty = @difficulty.to_i

      raise Invalid unless (1..3).include?(@difficulty)

    rescue Quit
      exit
    rescue Invalid => e
      puts e.message
      retry
    end

  end



####### Making the board

  def make_board
    @board = {spaces: [1, 2, 3, 4, 5, 6, 7, 8, 9],
              spaces_indexs: [0, 0, 0, 0, 0, 0, 0, 0, 0]}
  end



####### Showing the board

  def show_board(board)
    puts "#{board[:spaces][0]} | #{board[:spaces][1]} | #{board[:spaces][2]}"
    puts "---------"
    puts "#{board[:spaces][3]} | #{board[:spaces][4]} | #{board[:spaces][5]}"
    puts "---------"
    puts "#{board[:spaces][6]} | #{board[:spaces][7]} | #{board[:spaces][8]}"
    puts ""
  end



####### Seeing if a board spot is taken

  def is_taken?(answer)
    return true if @board[:spaces_indexs][answer - 1] != 0
    false
  end



####### Seeing if anyone won

  def wins?
    player1_win = [1, 1, 1]
    player2_win = [2, 2, 2]

    row1 = [@board[:spaces_indexs][0], @board[:spaces_indexs][1], @board[:spaces_indexs][2]], [@board[:spaces][0], @board[:spaces][1], @board[:spaces][2]]
    row2 = [@board[:spaces_indexs][3], @board[:spaces_indexs][4], @board[:spaces_indexs][5]], [@board[:spaces][3], @board[:spaces][4], @board[:spaces][5]]
    row3 = [@board[:spaces_indexs][6], @board[:spaces_indexs][7], @board[:spaces_indexs][8]], [@board[:spaces][6], @board[:spaces][7], @board[:spaces][8]]
    column1 = [@board[:spaces_indexs][0], @board[:spaces_indexs][3], @board[:spaces_indexs][6]], [@board[:spaces][0], @board[:spaces][3], @board[:spaces][6]]
    column2 = [@board[:spaces_indexs][1], @board[:spaces_indexs][4], @board[:spaces_indexs][7]], [@board[:spaces][1], @board[:spaces][4], @board[:spaces][7]]
    column3 = [@board[:spaces_indexs][2], @board[:spaces_indexs][5], @board[:spaces_indexs][8]], [@board[:spaces][2], @board[:spaces][5], @board[:spaces][8]]
    diagonal1 = [@board[:spaces_indexs][0], @board[:spaces_indexs][4], @board[:spaces_indexs][8]], [@board[:spaces][0], @board[:spaces][4], @board[:spaces][8]]
    diagonal2 = [@board[:spaces_indexs][2], @board[:spaces_indexs][4], @board[:spaces_indexs][6]], [@board[:spaces][2], @board[:spaces][4], @board[:spaces][6]]
    @possiblities = [row1, row2, row3, column1, column2, column3, diagonal1, diagonal2]

    @possiblities.each do |possibility|
      possibility.each do |entry|
        if player1_win == entry
          puts "\e[H\e[2J"
          show_board(@board)
          puts "#{@player1.color("#AA7BFC")} wins!"
          exit
        elsif player2_win == entry
          puts "\e[H\e[2J"
          show_board(@board)
          puts @player2 == "Computer" ? "#{@player2.color("#5193C9")} wins!" : "#{@player2.color("#F2206D")} wins!"
          exit
        end
      end
    end
  end



####### Seeing if the game is over

  def game_over?
    wins?

    status = @board[:spaces].all? { |entry| entry.is_a? String }
    if status == true
      puts "\e[H\e[2J"
      show_board(@board)
      puts "Stalemate! No one wins!".color("#E6DC6D")
      exit
    end
  end



####### Turn

  def turn
    game_over?
    puts "\e[H\e[2J"
    show_board(@board)
  end



####### Player 1 Turns

  def player1_turn
    begin
      puts "#{@player1.color("#AA7BFC")}, where would you like to put a X?"
      @answer = gets.chomp

      raise Quit if @answer == "q"

      @answer = @answer.to_i

      raise Invalid unless (1..9).include?(@answer)

      raise Taken if is_taken?(@answer)

      @board[:spaces][@answer - 1] = "X".color("#AA7BFC")
      @board[:spaces_indexs][@answer - 1] = 1

    rescue Quit
      exit
    rescue Taken => e
      puts e.message
      retry
    rescue Invalid => e
      puts e.message
      retry
    end

    turn
    puts "#{@player1.color("#AA7BFC")}" + " selects #{@answer.to_s.color("#5DC018")}"
    @player2 == "Computer" ? computer_turn : player2_turn
  end



####### Player 2 Turns

  def player2_turn
    begin
      puts "#{@player2.color("#F2206D")}, where would you like to put an O?"
      @answer = gets.chomp

      raise Quit if @answer == "q"

      @answer = @answer.to_i

      raise Invalid unless (1..9).include?(@answer)

      raise Taken if is_taken?(@answer)

      @board[:spaces][@answer - 1] = "O".color("#F2206D")
      @board[:spaces_indexs][@answer - 1] = 2

    rescue Quit
      exit
    rescue Taken => e
      puts e.message
      retry
    rescue Invalid => e
      puts e.message
      retry
    end

    turn
    puts "#{@player2.color("#F2206D")}" + " selects #{@answer.to_s.color("#5DC018")}"
    player1_turn
  end



####### Computer Turns

  def computer_wins?
    @possiblities.each do |possibility|
      possibility[1].each do |entry|
        if @to_win.include?(possibility[0])
          @comp_answer = entry if entry.is_a? Fixnum
        end
      end
    end
  end

  def computer_block?
    @possiblities.each do |possibility|
      possibility[1].each do |entry|
        if @to_block.include?(possibility[0])
          @comp_answer = entry if entry.is_a? Fixnum
        end
      end
    end
  end

  def computer_turn
    begin
      @to_block = [[1,1,0], [1,0,1], [0,1,1]]
      @to_win = [[2,2,0], [2,0,2], [0,2,2]]
      @comp_answer = 0

      computer_wins?

      computer_block? if @comp_answer == 0

      @comp_answer = rand(0...9) + 1 if @comp_answer == 0

      (@difficulty - 1).times do
        level = rand(1..3)
        @comp_answer = rand(0...9) + 1 if level == 1
      end

      raise Taken if is_taken?(@comp_answer)

      @board[:spaces][@comp_answer - 1] = "O".color("#5193C9")
      @board[:spaces_indexs][@comp_answer - 1] = 2

    rescue Taken
      retry
    end

    turn
    puts "Computer".color("#5193C9") + " selects #{@comp_answer.to_s.color("#5DC018")}"
    player1_turn
  end

end

game = Game.new

