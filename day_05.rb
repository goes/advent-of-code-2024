require "./day"

class Day05 < Day
  def initialize
    super(5)
  end

  def reset
    @rules = []
    @updates = []
  end

  def parse_input
    read_lines.reject(&:empty?).each do |line|
      if line.chars.include? "|"
        @rules << Rule.new(line)
      else
        @updates << Update.new(line)
      end
    end
  end

  def solution_one
    @updates.sum { |update| update.value_if_valid(@rules) }
  end

  def solution_two
    @updates.sum { |update| update.value_if_invalid(@rules) }
  end
end

class Update
  def initialize(line)
    @pages = line.split(",").collect(&:to_i)
  end

  def valid?(rules)
    applicable = rules.select { |rule| (@pages & rule.values).size == 2 }
    applicable.all? do |rule|
      @pages.index(rule.x) < @pages.index(rule.y)
    end
  end

  def value_if_valid(rules)
    return 0 unless valid?(rules)
    return @pages[@pages.size / 2]
  end

  def value_if_invalid(rules)
    return 0 if valid?(rules)
    fixed_pages = fix(rules)
    return fixed_pages[@pages.size / 2]
  end

  def fix(rules)
    fixed_pages = @pages.dup
    rules.sort_by { |rule| rule.x }.each do |rule|
      next unless (fixed_pages & rule.values).size == 2
      next if (pos_x = fixed_pages.index(rule.x)) < (pos_y = fixed_pages.index(rule.y))
      fixed_pages.delete(rule.x)
      fixed_pages.insert(pos_y, rule.x)
    end
    fixed_pages
  end
end

class Rule
  attr_reader :x, :y

  def initialize(line)
    numbers = line.split("|").collect(&:to_i)
    @x, @y = numbers.first, numbers.last
  end

  def values
    [x, y]
  end
end

Day05.new.solve
