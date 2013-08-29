class Piece

  attr_reader :color
  attr_accessor :pos, :king, :board

  def initialize(color, position, board)
    @color = color
    @pos = position
    @king = false
    @board = board
  end

  def slide_moves
    white_slides = [[-1, -1], [1, -1]]
    red_slides = [[-1, 1], [1, 1]]

    if self.king
      slides = white_slides + red_slides
    elsif self.color == :white
      slides = white_slides
    elsif self.color == :red
      slides = red_slides
    end

    slides.map {|slide| [slide[0] + pos[0], slide[1] + pos[1]] }
  end

  def jump_moves
    white_jumps = [[-2, -2], [2, -2]]
    red_jumps = [[-2, 2], [2, 2]]

    if self.king
      jumps = white_jumps + red_jumps
    elsif self.color == :white
      jumps = white_jumps
    elsif self.color == :red
      jumps = red_jumps
    end

    jumps.map {|jump| [jump[0] + pos[0], jump[1] + pos[1]]}
  end

  def perform_moves!(move_sequence)
    slides = self.slide_moves

    if slides.include?(move_sequence.first)
      raise InvalidMoveError.new("Can't chain slide moves together") if
        move_sequence.length > 1
      self.board.perform_slide(self.pos, move_sequence.first)

    else # all jumps
      move_sequence.each do |move|
        jumps = self.jump_moves
        self.board.perform_jump(self.pos, move)
      end
    end
  end

  def promotion!
    return self if self.king
    goal_row = self.color == :white ? 0 : 7
    if self.pos[1] == goal_row
      self.king = true
    end
    self
  end

  def deep_dup(fake_board)
    fake_self = self.dup
    fake_self.board = fake_board
    fake_self.pos = self.pos.dup
    fake_self
  end

  def to_s
    str = ""
    if self.color == :white
      str << "37m"
    else
      str << "31m"
    end
    str << "\u25C9 " unless self.king # non-king
    str << "\u24DA " if self.king
    str
  end
end
