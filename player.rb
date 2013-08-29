class Player

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    # only implemented in subclasses
  end

  def show_board
    # only implemented in subclasses
  end

end

class HumanPlayer < Player

  attr_reader :color

  def initialize(color)
    super(color)
  end

  def get_move
    puts "Enter coordinates of starting piece and each destination."
    puts "Coordinates should be entered row before column. Separate"
    puts "distinct squares with spaces."
    puts "#{self.color.to_s.capitalize} to play."

    input = gets.chomp
    raise IOError.new("Invalid input") unless is_valid?(input)
    parse_input(input)
  rescue IOError => e
    puts e.message
    retry
  end

  def parse_input(input)
    coords = input.split(" ")
    start_pos = coords.shift.split("").map{|c| c.to_i} # first two chars
    destinations = []
    coords.each do |coord|
      destinations << coord.split("").map{|c| c.to_i} #sketchy
    end
    [start_pos] + destinations
  end

  def is_valid?(input)
    return false if input.length < 2
    input.each_char do |c|
      return false unless (("0".."7").include?(c) || c == " ")
    end

    input.split(" ").each {|coord| return false unless coord.length == 2}
    true
  end

  def show_board(board)
    puts board.render
  end

end