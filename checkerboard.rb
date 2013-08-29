class Board

  attr_accessor :board

  def initialize(board = nil)
    board = Array.new(8) { Array.new(8)} unless board
    @board = board

    place_pieces
  end

  def place_pieces
    pieces_per_side = 12 # each player gets 12 pieces
    red_rows = [0, 1, 2] # red starts in top 3 rows
    white_rows = [5, 6, 7]

    self.board.each_with_index do |col, i|
      #next unless red_rows.include?(i) || white_rows.include?(i)
      col.each_with_index do |row, j|
        next if (i + j).even? # pieces start on black squares
        if red_rows.include?(j)
          board[i][j] = Piece.new(:red, [i, j])
        elsif white_rows.include?(j)
          board[i][j] = Piece.new(:white, [i, j])
        end
      end
    end
  end

  def [](pos)
    board[pos[0]][pos[1]]
  end

  def []=(start_pos, piece)
    # raise RangeError.new("Position #{pos} out of range") unless in_range(pos)
    board[start_pos[0]][start_pos[1]] = piece
  end

  def in_range?(pos)
    pos[0] < self.board.length && pos[1] < self.board[0].length
  end

  def perform_slide(start_pos, end_pos)
    piece = self[start_pos]
    slides = piece.slide_moves

    # raise InvalidMoveError.new("That piece cannot slide there.") unless
      # slides.include?(end_pos)

    # raise InvalidMoveError.new("That space is occupied.") unless
      # board[end_pos].nil?

    self[end_pos] = self[start_pos]
    self[start_pos] = nil
    piece.pos = end_pos
  end

end
