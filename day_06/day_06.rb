require_relative "../day.rb"

class Day06 < Day
  DIRECTIONS = {
    0 => [0, -1],
    90 => [1, 0],
    180 => [0, 1],
    270 => [-1, 0],
  }

  def initialize
    super(6)
  end

  def reset
    @direction = 0
  end

  def parse_input
    @map = read_matrix
    @guard = locate_guard
  end

  def locate_guard
    (0..nr_of_columns - 1).each do |c|
      (0..nr_of_rows - 1).each do |r|
        return [c, r] if @map[r][c] == "^"
      end
    end
  end

  def solution_one
    move_guard(@map).uniq.size
  end

  def move_guard(map)
    trace = []
    stop = false
    walking_guard = @guard
    trace = [walking_guard]
    direction = @direction
    check_looping = false
    while !stop
      new_pos = DIRECTIONS[direction].zip(walking_guard).map { |x, y| x + y }

      if out_of_map?(new_pos)
        stop = true
      elsif map_at(map, new_pos) == "#"
        direction = (direction + 90) % 360
        check_looping = true
      else
        trace << new_pos
        if check_looping
          return :loop if looping?(trace, new_pos)
          check_looping = false
        end
        walking_guard = new_pos
      end
    end
    trace
  end

  def looping?(trace, new_pos)
    return false unless trace.include?(new_pos)

    last, pre_last = trace[-1], trace[-2]
    return trace.first(trace.size - 2).each_cons(2).any? { |a| a.first == pre_last && a.last == last }
  end

  def out_of_map?(pos)
    return true if pos.first < 0 || pos.last < 0
    return true if pos.first > nr_of_columns - 1 || pos.last > nr_of_rows - 1
    false
  end

  def map_at(map, arr)
    map[arr.last][arr.first]
  end

  def adjacent(pos)
    result = [pos]
    result << ([pos.first - 1, pos.last]) if (pos.first > 0)
    result << [pos.first + 1, pos.last] if (pos.first < nr_of_columns - 1)
    result << [pos.first, pos.last - 1] if (pos.last > 0)
    result << [pos.first, pos.last + 1] if (pos.last < nr_of_rows - 1)
    result
  end

  def solution_two
    result = []
    to_try = move_guard(@map).uniq
    to_try = to_try.flat_map { |t| adjacent(t) }.uniq

    blocking_map = @map.clone
    to_try.each do |pos|
      next if (old_val = map_at(blocking_map, pos)) == "#"

      blocking_map[pos.last][pos.first] = "#"
      result << pos if move_guard(blocking_map) == :loop
      blocking_map[pos.last][pos.first] = "."
    end
    result.uniq.size
  end
end

Day06.new.solve
