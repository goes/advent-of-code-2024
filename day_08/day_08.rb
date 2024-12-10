require_relative "../day.rb"

class Day08 < Day
  def initialize
    super(8)
  end

  def reset
    @antennas = []
  end

  def parse_input
    read_matrix
    @antennas = matrix_elements.reject { |el| el.value == "." }.collect { |el| Antenna.new(el.x, el.y, el.value) }
  end

  def solution_one
    antinodes = @antennas
      .combination(2)
      .to_a
      .flat_map { |a1, a2| antinodes_one(a1, a2) }
      .select { |an| matrix_contains?(an.x, an.y) }
      .uniq { |an| an.coordinates }
    antinodes.size
  end

  def solution_two
    antinodes = @antennas
      .combination(2)
      .to_a
      .flat_map { |a1, a2| antinodes_two(a1, a2) }
      .uniq { |an| an.coordinates }
    antinodes.size
  end

  def antinodes_one(antenna1, antenna2)
    return [] unless antenna2.signal == antenna1.signal

    dx, dy = antenna2.x - antenna1.x, antenna2.y - antenna1.y

    [Antinode.new(antenna1.x - dx, antenna1.y - dy), Antinode.new(antenna2.x + dx, antenna2.y + dy)]
  end

  def antinodes_two(antenna1, antenna2)
    return [] unless antenna2.signal == antenna1.signal

    #debugger if antenna1.coordinates == [2, 5]
    result = []
    dx, dy = antenna2.x - antenna1.x, antenna2.y - antenna1.y

    x, y = antenna1.x, antenna1.y
    distance = 0
    while matrix_contains?(x, y)
      x, y = antenna1.x - distance * dx, antenna1.y - distance * dy
      result << Antinode.new(x, y) if matrix_contains?(x, y)
      distance += 1
    end

    x, y = antenna2.x, antenna2.y
    distance = 0
    while matrix_contains?(x, y)
      x, y = antenna2.x + distance * dx, antenna2.y + distance * dy
      result << Antinode.new(x, y) if matrix_contains?(x, y)
      distance += 1
    end

    result
  end
end

class Device
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def coordinates
    [x, y]
  end
end

class Antenna < Device
  attr_accessor :signal

  def initialize(x, y, signal)
    super(x, y)
    @signal = signal
  end
end

class Antinode < Device
end

Day08.new.solve
