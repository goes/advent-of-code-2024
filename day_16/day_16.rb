require_relative "../day.rb"

class Day16 < Day
  def initialize
    super(16)
  end

  def reset
    @maze, @trails = nil, nil
    @score_cache = {}
  end

  def parse_input
    setup_maze(read_lines)
  end

  def setup_maze(lines)
    @maze = Map.new_from_input_lines(lines)
    @trails = [Trail.new(@maze.locations_flattened.detect(&:is_start?))]
  end

  def solution_one
    successes = successful_paths
    successes.collect(&:score).min
  end

  def solution_two
    bests = successful_paths
    top_score = bests.collect(&:score).min
    bests = bests.select { |best| best.score == top_score }

    bests.flat_map(&:locations).uniq.size
  end

  def successful_paths
    successes = []

    new_trails = @trails.flat_map { |trail| trail.descendant_trails }
    while !new_trails.empty?
      new_successes = new_trails.select(&:is_success?)
      successes += new_successes
      new_trails = clean(new_trails).flat_map { |trail| trail.descendant_trails }
    end

    successes
  end

  def clean(trails)
    trails.each { |t| @score_cache[t.key] = t.score if !@score_cache[t.key] || t.score < @score_cache[t.key] }
    inefficient = trails.select { |ineft| ineft.score > @score_cache[ineft.key] }
    trails - inefficient
  end
end

# Trail
class Trail
  attr_accessor :moves, :locations, :direction, :head

  def initialize(loc)
    @maze = loc.map
    @direction = [1, 0]
    @moves = []
    @locations = [loc]
    reset_cache
  end

  def initialize_dup(source)
    @moves = source.moves.dup
    @locations = source.locations.dup
    super
  end

  def reset_cache
    @score = nil
    @head = @locations.last
  end

  def to_s
    "<Trail: (#{head&.x}, #{head&.y}) -> (#{@direction&.first}, #{@direction&.last}) - #{@moves.size} moves>"
  end

  def inspect
    to_s
  end

  def key
    [head.x, head.y, direction.first, direction.last]
  end

  def score
    @score ||= @moves.sum(&:score)
  end

  def destination
    @cached_destination ||= begin
        d = @maze.location_at(head.x + @direction.first, head.y + @direction.last)
        d.is_empty? ? d : nil
      end
  end

  def possible_moves
    moves = []

    destination = @maze.location_at(head.x + @direction.first, head.y + @direction.last)
    moves << Step.new(@direction, destination) unless (destination.is_wall?)

    head.neighbours.select { |n| n.is_empty? && @locations.none? { |l| l == n } }.each do |n|
      neighbour_direction = [n.x - head.x, n.y - head.y]
      moves << Turn.new(neighbour_direction) unless neighbour_direction == @direction
    end

    moves
  end

  def descendant_for_move(move)
    move.apply_to_trail(new_trail = dup)
    new_trail
  end

  def descendant_trails
    return [] if is_success?

    possible_moves.collect { |move| descendant_for_move(move) }
  end

  def is_success?
    head.is_end?
  end
end

# Move etc
class Move
  attr_accessor :direction

  def self.score
    raise NotImplementedError
  end

  def score
    self.class.score
  end

  def initialize(direction)
    @direction = direction
  end

  def apply_to_trail(trail)
    trail.moves << self
    trail.reset_cache
  end
end

class Turn < Move
  def self.score
    1000
  end

  def apply_to_trail(trail)
    super
    trail.direction = @direction
  end
end

class Step < Move
  def self.score
    1
  end

  def initialize(direction, destination)
    super(direction)
    @destination = destination
  end

  def apply_to_trail(trail)
    super
    trail.locations << @destination
    trail.head = @destination
  end
end

# Location
class Location
  def is_start?
    self.value == "S"
  end

  def is_end?
    self.value == "E"
  end

  def is_wall?
    self.value == "#"
  end

  def is_empty?
    self.value == "."
  end
end

Day16.new.solve
