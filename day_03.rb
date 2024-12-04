require "./day"

class Day03 < Day
  attr_accessor :program, :instructions

  REGEXP_ONE = /mul\((\d{1,3}),(\d{1,3})\)/
  REGEXP = /(do\(\)|don't\(\)|mul\(\d{1,3},\d{1,3}\))/

  def initialize
    super(3)
  end

  def reset
    super
    self.instructions = []
  end

  def parse_input
    self.program = read_lines.join("").scan(REGEXP).flatten
  end

  def solution_one
    self.instructions = program
      .select { |command| command.match(/^mul/) }
      .collect { |command| parse_instruction(command) }
    self.instructions.collect(&:result).sum
  end

  def solution_two
    enabled = true
    self.program.each do |command|
      case command
      when "do()"
        enabled = true
      when "don't()"
        enabled = false
      else
        self.instructions.push(parse_instruction(command, enabled:))
      end
    end
    self.instructions.collect(&:result).sum
  end

  def parse_instruction(command, enabled: true)
    factors = command.gsub(/[mul()]/, "")
      .split(",")
      .collect(&:to_i)
    Instruction.new(factors, enabled: enabled)
  end
end

class Instruction
  attr_accessor :factors, :enabled

  def initialize(factors, enabled: true)
    self.factors = factors
    self.enabled = enabled
  end

  def result
    return 0 unless enabled

    factors.inject(:*)
  end
end

Day03.new.solve
