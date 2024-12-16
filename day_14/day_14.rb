require_relative "../day.rb"

class Day14 < Day
  def initialize
    super(14)
  end

  def width
    mode == :test ? 11 : 101
  end

  def length
    mode == :test ? 7 : 103
  end

  def reset
    @room = Map.new_from_dimensions(width, length, initial_value: [])
    @robots = []
  end

  def parse_input
    @robots = read_lines.collect do |line|
      x, y, dx, dy = line.scan(/-?\d+/).map(&:to_i)
      loc = @room.location_at(x, y)
      debugger unless loc
      Robot.new(loc, dx, dy)
    end
  end

  def solution_one
    @robots.each { |r| r.move(100) }
    @robots.select { |r| r.quadrant(width, length) }.group_by { |r| r.quadrant(width, length) }.values.inject(1) { |result, array| result *= array.size }
  end

  def solution_two
    return -1 if mode == :test
    i = 442
    @robots.each { |r| r.move(i) }
    christmas = false
    while !christmas
      i += 1
      draw_image if (i % 100).zero?
      puts "i: #{i}" if (i % 100).zero?
      @robots.each { |r| r.move(1) }
      christmas = image_lines.any? { |line| line.match?(/888888888/) }
    end
    draw_image
    i
  end

  def draw_image
    image_lines.each { |l| puts l }
  end

  def image_lines
    lines = []
    (0..length).each do |y|
      lines << (0..width).each.inject("") do |str, x|
        str += (@robots.any? { |r| r.is_at?(x, y) }) ? "8" : "."
        str
      end
    end
    lines
  end
end

class Robot
  attr_accessor :dx, :dy, :location

  def initialize(location, dx, dy)
    @location, @dx, @dy = location, dx, dy
  end

  def room
    location.map
  end

  def move(times)
    x, y = location.x, location.y
    times.times do
      x = (val = (x + dx) % room.nr_of_columns).negative? ? val + room.nr_of_columns : val
      y = (val = (y + dy) % room.nr_of_rows).negative? ? val + room.nr_of_rows : val
    end

    self.location = room.location_at(x, y)
  end

  def is_at?(x, y)
    self.location.x == x && self.location.y == y
  end

  def quadrant(max_x, max_y)
    return nil if location.x == max_x / 2 || location.y == max_y / 2
    [location.x < max_x / 2, location.y < max_y / 2]
  end
end

Day14.new.solve
