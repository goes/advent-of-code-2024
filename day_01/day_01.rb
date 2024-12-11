require "./day"

class Day01 < Day
  def initialize
    super(1)
    @left_list, @right_list = []
  end

  def parse_input
    lines = read_lines
    @left_list, @right_list = lines.collect { |l| l.split(" ").collect(&:to_i) }.transpose
  end

  def solution_one
    @left_list
      .sort
      .zip(@right_list.sort)
      .collect { |left, right| (left - right).abs }
      .sum
  end

  def solution_two
    similarities = @right_list.tally
    @left_list.inject(0) { |total, nr| total + nr * (similarities[nr] || 0) }
  end
end

Day01.new.solve
