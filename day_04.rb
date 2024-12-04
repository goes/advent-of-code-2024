require "./day"

class Day04 < Day
  attr_accessor :puzzle

  def initialize
    super(4)
  end

  def reset
    self.puzzle = Puzzle.new(parse_input)
  end

  def parse_input
    read_matrix
  end

  def solution_one
    puzzle.all_xmasses.size
  end

  def solution_two
    puzzle.all_masses.size
  end
end

class Puzzle
  attr_reader :matrix, :nr_of_rows, :nr_of_columns

  def initialize(matrix)
    @matrix = matrix
    @nr_of_rows = self.matrix.size
    @nr_of_columns = self.matrix.first.size
  end

  def char(x, y)
    matrix[x][y]
  end

  def all_xmasses
    (0..nr_of_columns - 1).flat_map do |x|
      (0..nr_of_rows - 1).flat_map do |y|
        xmasses(x, y)
      end
    end
  end

  def xmasses(x, y)
    return [] unless char(x, y) == "X"
    masses = (-1..1).flat_map do |i|
      (-1..1).flat_map do |j|
        (1..3).collect do |d|
          xd, yd = x + d * i, y + d * j
          next unless xd.between?(0, nr_of_columns - 1)
          next unless yd.between?(0, nr_of_rows - 1)
          char(xd, yd)
        end.join("")
      end
    end
    masses.select { |w| w == "MAS" }
  end

  def all_masses
    masses = []
    (0..nr_of_columns - 1).each do |x|
      (0..nr_of_rows - 1).each do |y|
        masses << [x, y] if mas?(x, y)
      end
    end
    masses
  end

  def mas?(x, y)
    return false unless x.between?(1, nr_of_columns - 2)
    return false unless y.between?(1, nr_of_rows - 2)
    return false unless char(x, y) == "A"

    mas_1 = [char(x - 1, y - 1), "A", char(x + 1, y + 1)].join("")
    mas_2 = [char(x - 1, y + 1), "A", char(x + 1, y - 1)].join("")
    ([mas_1, mas_1.reverse].include? "MAS") && ([mas_2, mas_2.reverse].include? "MAS")
  end
end

Day04.new.solve
