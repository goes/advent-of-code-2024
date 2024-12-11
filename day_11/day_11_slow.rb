require_relative "../day.rb"

class Day11 < Day
  def initialize
    super(11)
  end

  def reset
    @map = nil
  end

  def parse_input
    @stones = read_lines.first.split(" ").collect { |s| Stone.new(s.to_i) }
  end

  def solution_one
    solution(@stones, 25)
  end

  def solution_two
    solution(@stones, 75)
  end

  def solution(stones, iterations)
    new_stones = stones
    (1..iterations).each do |it|
      time = Benchmark.realtime do
        new_stones = new_stones.flat_map(&:blink)
      end
      puts "#{time} - #{it} - #{new_stones.size}"
    end

    new_stones.size
  end
end

class Stone
  @@cache = {}

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def blink
    @@cache.fetch(@value) { @@cache[@value] = calculate_blink }
  end

  def calculate_blink
    return [Stone.new(1)] if value.zero?
    return split_values.collect { |val| Stone.new(val) } if @value.to_s.size.even?
    [Stone.new(value * 2024)]
  end

  def split_values
    str = value.to_s
    [str.chars.first(str.size / 2).join("").to_i, str.chars.last(str.size / 2).join("").to_i]
  end
end

Day11.new.solve
