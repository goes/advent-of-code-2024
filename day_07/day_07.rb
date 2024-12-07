require_relative "../day.rb"
require "ostruct"

class Day07 < Day
  def initialize
    super(7)
  end

  def reset
    @equations = []
  end

  def parse_input
    @equations = read_lines.collect { |line| Equation.new(line) }
  end

  def solution_one
    @equations.sum(&:solution)
  end

  def solution_two
    @equations.sum(&:solution_concat)
  end
end

class Equation
  def initialize(line)
    @result = line.split(":").first.strip.to_i
    @values = line.split(":").last.split(" ").collect(&:to_i)
  end

  def solution
    results = possible_operations.collect { |op| OpenStruct.new(operation: op, value: operation_value(op)) }
    return @result if results.any? { |result| result.value == @result }
    0
  end

  def solution_concat
    results = possible_operations_concat.collect { |op| OpenStruct.new(operation: op, value: operation_value(op)) }
    return @result if results.any? { |result| result.value == @result }
    0
  end

  def operation_value(operation)
    (operation.zip(@values.drop(1))).inject(@values.first) do |res, a|
      case a.first
      when :sum
        res + a.last
      when :product
        res * a.last
      when :concat
        "#{res}#{a.last}".to_i
      end
    end
  end

  def possible_operations
    result = [[:sum], [:product]]
    (@values.size - 2).times do
      s = result.dup.collect { |a| a.dup << :sum }
      p = result.dup.collect { |a| a.dup << :product }
      result = s + p
    end
    result
  end

  def possible_operations_concat
    result = [[:sum], [:product], [:concat]]
    (@values.size - 2).times do
      s = result.dup.collect { |a| a.dup << :sum }
      p = result.dup.collect { |a| a.dup << :product }
      c = result.dup.collect { |a| a.dup << :concat }
      result = s + p + c
    end
    result
  end
end

Day07.new.solve
