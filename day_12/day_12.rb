require_relative "../day.rb"

class Day12 < Day
  def initialize
    super(12)
  end

  def reset
    @garden = nil
    @regions = []
  end

  def parse_input
    @garden = Map.new(read_lines)
    @garden.locations_flattened.each { |loc| assign_region(loc) }
    @regions = merge_all_regions
  end

  def solution_one
    @regions.sum(&:price_one)
  end

  def solution_two
    @regions.sum(&:price_two)
  end

  def merge_all_regions
    @regions.group_by(&:plant).transform_values { |grp| merge_regions(grp) }.values.flatten
  end

  def merge_regions(regions)
    return regions if regions.size == 1

    to_merge = regions.combination(2).detect { |arr| arr.first.can_merge?(arr.last) }
    if to_merge
      to_merge.first.merge(to_merge.last)
      regions.delete(to_merge.last)
      merge_regions(regions)
    else
      regions
    end
  end

  def assign_region(loc)
    region = @regions.detect { |r| r.should_include?(loc) }
    if region
      region.add_location(loc)
    else
      @regions << Region.new(loc)
    end
  end
end

class Region
  attr_accessor :plant, :locations, :neighbours

  def initialize(location)
    @locations = [location]
    @plant = location.value
  end

  def neighbours(diagonals: false)
    @neighbours_cache ||= @locations.flat_map { |l| l.neighbours(diagonals:) }.uniq - @locations
  end

  def should_include?(loc)
    return false unless loc.value == @plant

    neighbours.include?(loc)
  end

  def add_location(loc)
    @locations << loc
    @neighbours_cache = nil
  end

  def add_locations(locs)
    locs.each { |loc| add_location(loc) }
  end

  def can_merge?(other_region)
    other_region.locations.any? { |l| neighbours.include?(l) }
  end

  def merge(other_region)
    add_locations(other_region.locations)
  end

  def perimeter_one
    @locations.sum { |l| 4 - l.neighbours.select { |n| n.value == l.value }.size }
  end

  def perimeter_two
    self.borders.size
  end

  def price_one
    perimeter_one * locations.size
  end

  def price_two
    perimeter_two * locations.size
  end

  def borders
    borders = []
    locations.each do |loc|
      borders << { x: loc.x, y: loc.y, dir: :left } unless (locations.any? { |n| n.x == loc.x - 1 && n.y == loc.y })
      borders << { x: loc.x, y: loc.y, dir: :right } unless (locations.any? { |n| n.x == loc.x + 1 && n.y == loc.y })
      borders << { x: loc.x, y: loc.y, dir: :up } unless (locations.any? { |n| n.x == loc.x && n.y == loc.y - 1 })
      borders << { x: loc.x, y: loc.y, dir: :down } unless (locations.any? { |n| n.x == loc.x && n.y == loc.y + 1 })
    end
    borders = borders.reject { |b1| borders.select { |b2| b1[:dir] == b2[:dir] && b1[:x] == b2[:x] }.any? { |b2| (b1[:y] - b2[:y]) == 1 } }
    borders = borders.reject { |b1| borders.select { |b2| b1[:dir] == b2[:dir] && b1[:y] == b2[:y] }.any? { |b2| (b1[:x] - b2[:x]) == 1 } }
    borders
  end
end

Day12.new.solve
