require "debug"

class Day
  attr_accessor :mode, :day

  def initialize(day)
    self.day = day
    self.mode = :test
    reset
  end

  def reset
  end

  def file_name
    "./input/day_%02d_#{mode == :test ? 1 : 2}.txt" % self.day
  end

  def read_lines
    File.readlines(file_name)
  end

  def read_matrix
    rows = read_lines
    matrix = rows.collect { |row| row.strip.chars }
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
