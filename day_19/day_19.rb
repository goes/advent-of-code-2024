require_relative "../day.rb"

class Day19 < Day
  def initialize
    super(19)
  end

  def reset
    @racetrack, start = nil, nil
    @all_scores = {}
  end

  def parse_input
    setup_racetrack(read_lines)
  end

  def setup_racetrack(lines)
    @racetrack = Map.new_from_input_lines(lines)
  end

  def solution_one
    time = Path.new(@racetrack.dup).tap(&:solve).score
    puts time

    initialize_all_paths
    return @all_scores.values.compact.count { |score| score <= (time - 100) }
  end

  def solution_two
    0
  end

  def initialize_all_paths
    (1..(@racetrack.nr_of_columns - 2)).each do |x|
      (1..(@racetrack.nr_of_rows - 2)).each do |y|
        racetracks = []
        next unless @racetrack.location_at(x, y).is_wall?

        if @racetrack.location_at(x - 1, y).is_shortcuttable? && @racetrack.location_at(x + 1, y).is_shortcuttable?
          dupl = @racetrack.dup.tap { |t| t.location_at(x, y).value = "1" }.tap { |t| t.set_value(x - 1, y, "2", only_if_empty: true) }
          dupl.location_at(x - 1, y).neighbours.select(&:is_empty?).each do |n|
            racetracks << dupl.dup.tap { |t| t.location_at(n.x, n.y).value = "#" }
          end
          dupl = @racetrack.dup.tap { |t| t.location_at(x, y).value = "1" }.tap { |t| t.set_value(x + 1, y, "2", only_if_empty: true) }
          dupl.location_at(x + 1, y).neighbours.select(&:is_empty?).each do |n|
            racetracks << dupl.dup.tap { |t| t.location_at(n.x, n.y).value = "#" }
          end
        end
        if @racetrack.location_at(x, y - 1).is_shortcuttable? && @racetrack.location_at(x, y + 1).is_shortcuttable?
          dupl = @racetrack.dup.tap { |t| t.location_at(x, y).value = "1" }.tap { |t| t.set_value(x, y - 1, "2", only_if_empty: true) }
          dupl.location_at(x, y - 1).neighbours.select(&:is_empty?).each do |n|
            racetracks << dupl.dup.tap { |t| t.location_at(n.x, n.y).value = "#" }
          end
          dupl = @racetrack.dup.tap { |t| t.location_at(x, y).value = "1" }.tap { |t| t.set_value(x, y + 1, "2", only_if_empty: true) }
          dupl.location_at(x, y + 1).neighbours.select(&:is_empty?).each do |n|
            racetracks << dupl.dup.tap { |t| t.location_at(n.x, n.y).value = "#" }
          end
        end
        paths = racetracks.collect { |tr| Path.new(tr).tap(&:solve) }
        paths.select(&:score).uniq { |p| p.locations_array }.each do |p|
          @all_scores[p] = p.score
        end
        log "#{[x, y]} - tracks: #{racetracks.empty? ? "-" : racetracks.size} - Scores: #{@all_scores.compact.size}"
      end
    end
  end

  def track_duplicate_with_cheat(track, x, y)
  end
end

# Location
class Location
  def is_start?
    self.value == "S"
  end

  def is_shortcut?
    self.value == "1"
  end

  def is_shortcuttable?
    return false if is_wall?
    true
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

# Path
class Path
  attr_accessor :locations, :head

  def initialize(map)
    @head = map.locations_flattened.detect(&:is_start?)
    debugger unless @head
    @locations = [@head]
    score = nil
  end

  def initialize_dup(source)
    @locations = source.locations.dup
    @head = @locations.last
    super
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

  def locations_array
    @locations.collect { |loc| [loc.x, loc.y] }
  end

  def score
    is_success? ? @locations.size - 1 : nil
  end

  def solve
    ended = false
    while !ended
      current_head = @head
      move
      ended = @head == current_head || @head.is_end?
    end
    score
  end

  def move
    n = head.neighbours.reject { |n| ["S", "#", "2", "O"].include?(n.value) }
    return if n.empty?
    if (shortcut = n.detect { |n| n.is_shortcut? })
      shortcut_2 = shortcut.neighbours.detect { |n| n.value == "2" }
      append(shortcut)
      append(shortcut_2) if shortcut_2
    else
      debugger if !n.size == 1
      append n.first
    end
  end

  def append(loc)
    loc.value = "O" unless loc.is_end?
    @locations << loc
    @head = loc
  end

  def is_success?
    head.is_end?
  end

  def print
    puts @head.map.locations_flattened.detect(&:is_shortcut?)
    (0..@head.map.nr_of_rows - 1).each do |y|
      line = ""
      (0..@head.map.nr_of_columns - 1).each do |x|
        line += @locations.any? { |l| l.x == x && l.y == y } ? "O" : @head.map.location_at(x, y).value
      end
      puts line
    end
  end
end

Day19.new.solve
