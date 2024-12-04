require "./day"

class Day02 < Day
  attr_accessor :reports

  def initialize
    super(2)
    self.reports = []
  end

  def parse_input
    self.reports = read_lines.collect do |l|
      Report.new(l.split(" ").collect(&:to_i))
    end
  end

  def solution_one
    reports.select(&:safe?).size
  end

  def solution_two
    reports.select(&:safe_reduced?).size
  end
end

class Report
  attr_accessor :levels, :values

  def initialize(values)
    self.values = values
    self.levels = values.each_cons(2).collect { |arr| arr.last - arr.first }
  end

  def safe?
    same_sign? && safe_operations?
  end

  def safe_reduced?
    safe? || reduced_reports.any?(&:safe?)
  end

  def same_sign?
    levels.collect { |level| level <=> 0 }.uniq.size == 1
  end

  def safe_operations?
    levels.all? { |level| level.abs.between?(1, 3) }
  end

  def reduced_reports
    (0..values.size).collect { |i| Report.new(values.dup.tap { |dup| dup.delete_at(i) }) }
  end
end

Day02.new.solve
