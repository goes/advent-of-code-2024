require "debug"
require "benchmark"

class Day
  attr_accessor :mode, :day, :matrix, :nr_of_rows, :nr_of_columns

  def initialize(day)
    self.day = day
    self.mode = :test
    reset
  end

  def reset
  end

  def parse_input
    raise NotImplementedError
  end

  def solve
    { 1 => :solution_one, 2 => :solution_two }.each do |idx, selector|
      solutions = %i[test real].collect do |mode|
        self.mode = mode
        reset
        parse_input
        send(selector)
      end

      puts "Dag #{@day}, deel #{idx}: #{solutions.join(", ")}"
    end
  end

  def file_name
    fn = ("#{__dir__}/day_%02d/input_#{mode}.txt" % self.day)
    return fn if File.exist?(fn)

    "./input/day_%02d_#{mode == :test ? 1 : 2}.txt" % self.day
  end

  def read_lines
    File.readlines(file_name).collect(&:strip)
  end

  def read_matrix
    rows = read_lines
    @matrix = rows.collect { |row| row.strip.chars }
    @nr_of_rows = @matrix.size
    @nr_of_columns = @matrix.first.size
    @matrix
  end

  def matrix_elements
    return [] unless @matrix
    (0..nr_of_columns - 1).flat_map do |x|
      (0..nr_of_rows - 1).collect do |y|
        MatrixElement.new(x, y, @matrix[x][y])
      end
    end
  end

  def matrix_contains?(x, y)
    x.between?(0, nr_of_columns - 1) && y.between?(0, nr_of_rows - 1)
  end

  def matrix_each
    (0..nr_of_columns - 1).each do |x|
      (0..nr_of_rows - 1).each do |y|
        yield x, y
      end
    end
  end
end

class MatrixElement
  attr_accessor :x, :y, :value

  def initialize(x, y, value)
    @x, @y, @value = x, y, value
  end
end

class MatrixElement
  attr_accessor :x, :y, :value

  def initialize(x, y, value)
    @x, @y, @value = x, y, value
  end
end

class Map
  attr_accessor :locations, :nr_of_rows, :nr_of_columns

  def initialize(lines, &value_block)
    @locations = []
    rows = lines.collect { |row| row.strip.chars }
    @nr_of_rows = rows.size
    @nr_of_columns = rows.first.size
    (0..nr_of_rows - 1).each do |y|
      @locations << []
      (0..nr_of_columns - 1).each do |x|
        input = rows[y][x]
        @locations.last << Location.new(x, y, value_block ? value_block.call(input) : input, self)
      end
    end
  end

  def locations_flattened
    @locations.flatten
  end

  def location_at(x, y)
    return nil unless x.between?(0, @nr_of_columns - 1)
    return nil unless y.between?(0, @nr_of_rows - 1)

    self.locations[y][x]
  end

  class Location
    attr_accessor :x, :y, :value

    def initialize(x, y, value, map)
      @x, @y, @value, @map = x, y, value, map
    end

    def neighbours(diagonals: false)
      possible = [[-1, 0], [1, 0], [0, -1], [0, 1]]
      possible = possible + [[-1, -1], [1, 1], [1, -1], [-1, 1]] if diagonals
      possible
        .collect { |a| @map.location_at(x + a.first, y + a.last) }
        .compact
    end

    def ==(other)
      x == other.x && y == other.y
    end

    def to_s
      "(#{x},#{y}) : #{value}"
    end

    def inspect
      to_s
    end
  end
end
