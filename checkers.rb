require_relative "checker_piece.rb"
require_relative "checkerboard.rb"
require_relative "player.rb"

class Checkers

  attr_accessor :board

  def initialize(player_1 = HumanPlayer.new(:red),
    player_2 = HumanPlayer.new(:white), start_board = nil)

    @board = Board.new unless start_board
    @red = player_1
    @white = player_2
  end

  def play
    loop do
      [@red, @white].each do |player|
        player.show_board(self.board)
        play_turn(player)
        if board.game_over?(@red, @white, opponent(player))
          puts "#{player.color} wins!"
          return
        end
      end
    end
  end

  def opponent(player)
    player == @red ? @white : @red
  end

  def play_turn(player)
    raw_move = player.get_move
    starting_pos = raw_move.shift
    self.board.perform_moves(starting_pos, raw_move)

    rescue InvalidMoveError => e
      puts e
      puts
      retry
  end

end
