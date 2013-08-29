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

    raise InvalidMoveError.new("That piece cannot slide there.") unless
      slides.include?(end_pos)

    raise InvalidMoveError.new("That space is occupied.") unless
      self[end_pos].nil?

    self[end_pos] = self[start_pos]
    self[start_pos] = nil
    piece.pos = end_pos
    # piece.promotion!
  end

  def perform_jump(start_pos, end_pos)
    piece = self[start_pos]
    jumps = piece.jump_moves

    raise InvalidMoveError.new("That piece cannot jump there.") unless
      jumps.include?(end_pos)

    raise InvalidMoveError.new("That space is occupied.") unless
      self[end_pos].nil?

    # find piece in the middle
    middle_pos = find_middle(start_pos, end_pos)
    middle_piece = self[middle_pos]

    # make sure it's an enemy piece
    raise InvalidMoveError.new("Cannot jump friendly piece") if
      piece.color == middle_piece.color

    # delete it
    self[middle_pos] = nil

    self[end_pos] = self[start_pos]
    self[start_pos] = nil
    piece.pos = end_pos
  end

  def find_middle(start_pos, end_pos)
    middle_pos = start_pos

    [0, 1].each do |i|
      if end_pos[i] > start_pos[i]
        middle_pos[i] += 1
      else
        middle_pos[i] -= 1
      end
    end

    middle_pos
  end

  def render
    str = "  0 1 2 3 4 5 6 7\n"

    # substr = "0 "
    # (0..7).each do |i|
    #   substr << "\033["
    #   substr << (i.even? ? "47" : "42")
    #
    #   unless self[[i, 0]].nil?
    #     substr << ";" << (self[[i, 0]]).to_s
    #   else
    #     substr << "m" << " "
    #     substr << " "
    #   end
    # end

    (0..7).each do |i|
      substr = "\033[0m#{i} "
      (0..7).each do |j|
        substr << "\033["
        substr << ((i + j).even? ? "47" : "42")

        unless self[[j, i]].nil?
          substr << ";" << (self[[j, i]]).to_s
        else
          substr << "m" << " "
          substr << " "
        end
      end
      str << substr << "\033[0m\n"
    end

    str
  end


end

class InvalidMoveError < StandardError

end

class RangeError < StandardError

end
