require_relative "../day.rb"

class Day11 < Day
  def initialize
    super(11)
  end

  def reset
    @stones = {}
  end

  def parse_input
    read_lines.first.split(" ").collect(&:to_i).each { |i| @stones[i] = (@stones[i] || 0) + 1 }
  end

  def solution_one
    solution(@stones, 25)
  end

  def solution_two
    solution(@stones, 75)
  end

  def solution(stones, iterations)
    (1..iterations).each do |it|
      new_stones = {}
      time = Benchmark.realtime do
        stones.each do |value, count|
          blink(value).each { |new_val| new_stones[new_val] = (new_stones[new_val] || 0) + count }
        end
      end
      stones = new_stones
      # puts "#{time} - #{it} - #{stones.values.sum}"
    end
    stones.values.sum
  end

  def blink(inscription)
    return [1] if inscription.zero?
    return split(inscription) if inscription.to_s.size.even?
    [inscription * 2024]
  end

  def split(val)
    str = val.to_s
    [str.chars.first(str.size / 2).join("").to_i, str.chars.last(str.size / 2).join("").to_i]
  end
end

Day11.new.solve
