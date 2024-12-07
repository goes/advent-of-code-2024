require "debug"

class Day
  attr_accessor :mode, :day, :matrix, :nr_of_rows, :nr_of_columns

  def initialize(day)
    self.day = day
    self.mode = :test
    reset
  end

  def reset
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
end
