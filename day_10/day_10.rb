require_relative "../day.rb"

class Day10 < Day
  def initialize
    super(10)
  end

  def reset
    @map = nil
  end

  def parse_input
    @map = Map.new(read_lines, &:to_i)
  end

  def solution_one
    trailheads.sum(&:score_one)
  end

  def solution_two
    trailheads.sum(&:score_two)
  end

  def trailheads
    @map.locations_flattened.select { |l| l.value.zero? }.collect { |l| TrailHead.new(l) }
  end
end

class TrailHead
  def initialize(location)
    @location = location
  end

  def score_one
    full_paths.collect(&:last).uniq.size
  end

  def score_two
    full_paths.size
  end

  def full_paths
    paths = [[@location]]
    (1..9).each do |i|
      paths = paths.flat_map do |path|
        valid_neighbours = path.last.neighbours.select { |n| n.value == i }
        valid_neighbours.collect { |n| path.dup << n }
      end
    end
    paths
  end
end

Day10.new.solve
