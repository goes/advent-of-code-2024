require_relative "../day.rb"

class Day15 < Day
  DIRECTIONS = {
    "<" => [-1, 0],
    ">" => [1, 0],
    "v" => [0, 1],
    "^" => [0, -1],
  }

  def initialize
    super(15)
  end

  def width
    mode == :test ? 11 : 101
  end

  def length
    mode == :test ? 7 : 103
  end

  def reset
    @warehouse, @instructions, @fish = nil, nil, nil
  end

  def parse_input
    @map_lines = read_lines.slice_before("").to_a.first
    @instructions = read_lines.slice_before("").to_a.last.flat_map { |line| line.chars }
  end

  def move_fish(x, y)
    @fish = @fish.move(x, y)
  end

  def setup_warehouse(lines)
    @warehouse = Map.new_from_input_lines(lines)
    @fish = @warehouse.locations_flattened.detect(&:is_fish?)
  end

  def solution(lines)
    setup_warehouse(lines)
    @instructions.each do |instr|
      move_fish(DIRECTIONS[instr].first, DIRECTIONS[instr].last)
      # system("clear")
      # @warehouse.print
    end
    @warehouse.locations_flattened.sum(&:box_distance)
  end

  def solution_one
    solution(@map_lines)
  end

  def solution_two
    solution(@map_lines.collect(&:scale))
  end
end

class Location
  def basic_move(dx, dy)
    destination = @map.location_at(x + dx, y + dy)
    return swap_with(destination) if destination.is_empty?

    destination.basic_move(dx, dy) if destination.can_move?(dx, dy)

    swap_with(destination) if destination.is_empty?
  end

  def move(dx, dy)
    destination = @map.location_at(x + dx, y + dy)
    return self if destination.is_wall?

    if destination.is_empty?
      swap_with(destination)
      return destination
    end

    if dx.zero? #pushing vertically
      box_cluster = build_box_cluster(dx, dy)
      return self unless box_cluster.flatten.all? { |loc| loc.can_move?(dx, dy) }

      box_cluster.reverse.each { |level| level.each { |loc| loc.basic_move(dx, dy) } }
    else
      destination.basic_move(dx, dy)
    end

    return self unless destination.value == "."

    swap_with(destination)
    return destination
  end

  def can_move?(dx, dy)
    return false if is_empty?
    return false if is_wall?

    destination = @map.location_at(x + dx, y + dy)

    destination.is_empty? || destination.can_move?(dx, dy)
  end

  def destination_box_with_counterpart(dx, dy)
    destination = @map.location_at(x + dx, y + dy)
    destination.is_box? ? [destination, destination.counterpart].compact : []
  end

  def build_box_cluster(dx, dy)
    tree = [destination_box_with_counterpart(dx, dy)]

    next_level = tree.last.flat_map { |loc| loc.destination_box_with_counterpart(dx, dy) }
    while !next_level.empty?
      tree << next_level.uniq
      next_level = tree.last.flat_map { |loc| loc.destination_box_with_counterpart(dx, dy) }
    end

    tree
  end

  def swap_with(destination)
    my_val = self.value
    self.value = destination.value
    destination.value = my_val
  end

  def box_distance
    return 0 unless ["O", "["].include? self.value
    100 * y + x
  end

  def is_fish?
    self.value == "@"
  end

  def is_wall?
    self.value == "#"
  end

  def is_empty?
    self.value == "."
  end

  def is_box?
    ["O", "[", "]"].include?(self.value)
  end

  def counterpart
    return @map.location_at(x + 1, y) if value == "["
    return @map.location_at(x - 1, y) if value == "]"
    nil
  end
end

class String
  SCALE_MAP = {
    "#" => "##",
    "O" => "[]",
    "." => "..",
    "@" => "@.",
  }

  def scale
    chars.inject("") { |result, char| result += SCALE_MAP[char] }
  end
end

Day15.new.solve
