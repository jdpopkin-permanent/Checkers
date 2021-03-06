class Board

  attr_accessor :board

  def initialize(board = nil)
    board = Array.new(8) { Array.new(8)} unless board
    @board = board

    place_pieces
  end

  def place_pieces
    red_rows = [0, 1, 2] # red starts in top 3 rows
    white_rows = [5, 6, 7]

    self.board.each_with_index do |col, i|
      col.each_with_index do |row, j|
        next if (i + j).even? # pieces start on black squares
        if red_rows.include?(j)
          board[i][j] = Piece.new(:red, [i, j], self)
        elsif white_rows.include?(j)
          board[i][j] = Piece.new(:white, [i, j], self)
        end
      end
    end
  end

  def [](pos)
    board[pos[0]][pos[1]]
  end

  def []=(start_pos, piece)
    raise RangeError.new("Position #{start_pos} out of range") unless in_range?(start_pos)
    board[start_pos[0]][start_pos[1]] = piece
  end

  def in_range?(pos)
    pos[0] < self.board.length && pos[1] < self.board[0].length &&
      pos[0] >= 0 && pos[1] >= 0
  end

  def perform_slide(start_pos, end_pos)
    boundary_checks(start_pos, end_pos)

    piece = self[start_pos]
    slides = piece.slide_moves

    raise InvalidMoveError.new("That piece cannot slide there.") unless
      slides.include?(end_pos)

    update_endpoints(start_pos, end_pos)
  end

  def boundary_checks(start_pos, end_pos)
    raise InvalidMoveError.new("No such piece") if self[start_pos].nil?

    raise InvalidMoveError.new("That space is occupied.") unless
      self[end_pos].nil?
  end

  def perform_jump(start_pos, end_pos)
    boundary_checks(start_pos, end_pos)

    piece = self[start_pos]
    jumps = piece.jump_moves

    raise InvalidMoveError.new("That piece cannot jump there.") unless
      jumps.include?(end_pos)

    # find piece in the middle
    middle_pos = find_middle(start_pos, end_pos)
    middle_piece = self[middle_pos]

    raise InvalidMoveError.new("Nothing to jump") if
      middle_piece.nil?

    # make sure it's an enemy piece
    raise InvalidMoveError.new("Cannot jump friendly piece") if
      piece.color == middle_piece.color

    # delete it
    self[middle_pos] = nil

    update_endpoints(start_pos, end_pos)
  end

  def update_endpoints(start_pos, end_pos)
    piece = self[start_pos]

    self[end_pos] = piece
    self[start_pos] = nil
    piece.pos = end_pos
    # piece.promotion! saved for end of the move sequence
  end

  def valid_move_sequence?(start_pos, move_sequence)
    piece = self[start_pos]
    return false unless piece # needed?

    fake_board = self.deep_dup
    fake_piece = fake_board[start_pos]

    begin
      fake_piece.perform_moves!(move_sequence)
    rescue InvalidMoveError => e
      return false
    end
    true
  end

  def force_jump(piece, move_sequence)
    if has_jump_move?(piece.color)
      jumps = piece.jump_moves.select{|jump| in_range?(jump)}
      raise InvalidMoveError.new("You must jump whenever possible!") unless
        jumps.include?(move_sequence.first)
    end
  end

  def perform_moves(start_pos, move_sequence)
    piece = self[start_pos]
    raise InvalidMoveError.new("No piece at that location") if piece.nil?

    force_jump(piece, move_sequence) # forces player to jump if possible

    if valid_move_sequence?(start_pos, move_sequence)
      piece.perform_moves!(move_sequence)
    else
      raise InvalidMoveError.new("Invalid move sequence.")
    end

    piece.promotion!
  end

  def has_any_move?(color)
    has_jump_move?(color) || has_slide_move?(color)
  end

  def has_jump_move?(color)
    # cycle through squares
    pieces = get_pieces_by_color(color)

    # test if any can jump
    pieces.any? {|piece| piece.can_jump?}
  end

  def has_slide_move?(color)
    # cycle through squares
    pieces = get_pieces_by_color(color)

    # test if any can slide
    pieces.any? {|piece| piece.can_slide?}
  end

  def get_pieces_by_color(color)
    pieces = []
    self.board.each do |row|
      row.each do |col|
        next if col.nil?
        pieces << col if col.color == color
      end
    end
    pieces
  end

  def game_over?(red, white, player)
    return true if get_pieces_by_color(:red).empty?
    return true if get_pieces_by_color(:white).empty?

    return true unless has_any_move?(player.color)
    false
  end

  def deep_dup
    fake_self = self.dup
    fake_self.board = []
    self.board.each do |row|
      fake_row = []

      row.each do |col|
        fake_row << col.deep_dup(fake_self) unless col.nil?
        fake_row << nil if col.nil?
      end

      fake_self.board << fake_row
    end
    fake_self
  end

  def find_middle(start_pos, end_pos)
    middle_pos = start_pos.dup

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
      str << substr << "\033[0m #{i}\n"
    end
    str << "  0 1 2 3 4 5 6 7\n"

    str
  end


end

class InvalidMoveError < StandardError
  attr_accessor :msg

  def initialize(msg = "Invalid move error")
    super(msg)
  end
end

class RangeError < StandardError
  attr_accessor :msg

  def initialize(msg)
    super(msg)
  end
end
