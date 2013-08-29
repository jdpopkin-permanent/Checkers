require_relative "checker_piece.rb"
require_relative "checkerboard.rb"

class Checkers

  attr_accessor :board

  def initialize(start_board = nil)
    @board = Board.new unless start_board
  end

end
