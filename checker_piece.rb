class Piece

  attr_reader :color
  attr_accessor :position, :king

  def initialize(color, position)
    @color = color
    @position = position
    @king = false
  end

  def all_slides
    white_slides = [[-1, 1], [1, 1]]
    red_slides = [[-1, -1], [1, -1]]

    return white_slides + red_slides if self.king?
    return white_slides if self.color == :white
    return red_slides if self.color == :red
  end


end