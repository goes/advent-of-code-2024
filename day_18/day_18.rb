require_relative "../day.rb"

class Day18 < Day
  def initialize
    super(18)
  end

  def reset
    @memory = nil
    @bytes = []
    @score_cache = {}
  end

  def parse_input
    @bytes = read_lines.collect { |line| line.split(",").collect(&:to_i) }
  end

  def setup_memory(dim)
    @memory = Map.new_from_dimensions(dim, dim, initial_value: ".")
  end

  def solution_one
    reset_memory(mode == :test ? 12 : 1024)
    successful_paths.map(&:score).min
  end

  def solution_two
    i = (mode == :test ? 12 : 1024)
    reset_memory(i)

    sucessful = successful_paths
    while !sucessful.empty?
      reset_memory(i += 1)
      sucessful = successful_paths
    end
    "#{@bytes[i - 1]}"
  end

  def reset_memory(nr_of_bytes)
    @score_cache = {}
    setup_memory(mode == :test ? 7 : 71)
    @bytes.first(nr_of_bytes).each { |b| @memory.location_at(b.first, b.last).value = "#" }
  end

  def successful_paths
    successes = []

    paths = Path.new(@memory).descendant_paths
    while !paths.empty?
      new_successes = paths.select(&:is_success?)
      successes += new_successes
      paths = optimize(paths).flat_map { |paths| paths.descendant_paths }
    end

    successes
  end

  def optimize(paths)
    paths.each { |p| @score_cache[p.key] = p.score if !@score_cache[p.key] || p.score < @score_cache[p.key] }
    inefficient = paths.select { |inefp| inefp.score > @score_cache[inefp.key] }
    paths = paths - inefficient
    paths.group_by { |p| { p.key => p.score } }.values.collect(&:first)
  end
end

# Location
class Location
  def is_start?
    self.x == 0 && self.y == 0
  end

  def is_empty?
    self.value == "."
  end
end

# Path
class Path
  attr_accessor :locations, :head

  def initialize(map)
    @locations = [map.location_at(map.nr_of_columns - 1, map.nr_of_rows - 1)]
    reset_cache
  end

  def initialize_dup(source)
    @locations = source.locations.dup
    reset_cache
    super
  end

  def reset_cache
    @score = nil
    @head = @locations.last
  end

  def to_s
    "<Path: (#{head&.x}, #{head&.y}) - #{@locations.size} locations>"
  end

  def inspect
    to_s
  end

  def key
    [head.x, head.y]
  end

  def score
    @score ||= @locations.size - 1
  end

  def possible_moves
    head.neighbours.select { |n| n.is_empty? && @locations.none? { |l| l == n } }
  end

  def append(loc)
    @locations << loc
    reset_cache
  end

  def descendant_for_move(loc)
    dup.tap { |p| p.append(loc) }
  end

  def descendant_paths
    return [] if is_success?

    possible_moves.collect { |loc| descendant_for_move(loc) }
  end

  def is_success?
    head.is_start?
  end

  def print
    (0..@head.map.nr_of_rows - 1).each do |y|
      line = ""
      (0..@head.map.nr_of_columns - 1).each do |x|
        line += @locations.any? { |l| l.x == x && l.y == y } ? "O" : @head.map.location_at(x, y).value
      end
      puts line
    end
  end
end

Day18.new.solve
