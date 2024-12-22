require_relative "../day.rb"

class Day19 < Day
  def initialize
    super(19)
  end

  def reset
    @patterns = []
    @designs = []
    Design.reset_cache
  end

  def parse_input
    @towels = read_lines.first.split(",").map { |pattern| Towel.new(pattern.strip) }
    @designs = read_lines[2..].map { |pattern| Design.new(pattern.strip, @towels) }
  end

  def solution_one
    @designs.select(&:possible?).size
  end

  def solution_two
    @designs.select(&:possible?).sum(&:nr_of_towel_combinations)
  end
end

class Design
  @@cache = {}

  def self.reset_cache
    @@cache = {}
  end

  def self.cache
    @@cache
  end

  def initialize(pattern, towels)
    @pattern, @available_towels = pattern, towels.sort_by { |t| 0 - t.size }
  end

  def possible?
    pattern_possible?(@pattern)
  end

  def pattern_possible?(to_match)
    return true if @available_towels.any? { |t| t.pattern == to_match }

    possibilities = @available_towels.select { |t| t.pattern == to_match[0..(t.size - 1)] }
    return false if possibilities.empty?
    possibilities.collect { |t| to_match[t.size..] }.any? { |sub_pat| pattern_possible?(sub_pat) }
  end

  def nr_of_towel_combinations
    return [] unless possible?
    @@cache = {} if @halt

    nr_of_towel_combinations_for(@pattern)
  end

  def nr_of_towel_combinations_for(to_match)
    if @@cache[to_match]
      #  puts "====> Cache hit:  #{to_match} (#{@@cache.size})"
      return @@cache[to_match]
    end

    result = 0
    @available_towels.select { |t| t.pattern == to_match[0..(t.size - 1)] }.collect do |t|
      result += 1 if t.pattern == to_match
      next if to_match[t.size..] == ""
      result += nr_of_towel_combinations_for(to_match[t.size..])
    end

    @@cache[to_match] = result
    #  puts "====> *** Calculated: #{to_match} (Cache size: #{@@cache.size})"
    result
  end
end

class Towel
  attr_accessor :pattern

  def initialize(pattern)
    @pattern = pattern
  end

  def size = @pattern.size
end

Day19.new.solve
