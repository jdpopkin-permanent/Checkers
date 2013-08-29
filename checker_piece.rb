class Piece

  attr_reader :color
  attr_accessor :pos, :king

  def initialize(color, position)
    @color = color
    @pos = position
    @king = false
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


end