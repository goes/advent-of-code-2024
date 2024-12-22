require_relative "../day.rb"

class Day17 < Day
  def initialize
    super(17)
  end

  def reset
    @computer = nil
  end

  def parse_input
    lines = read_lines
    a = lines[0].scan(/\b-?\d+\b/).first.to_i
    b = lines[1].scan(/\b-?\d+\b/).first.to_i
    c = lines[2].scan(/\b-?\d+\b/).first.to_i
    instructions = lines[4].split(":").last.strip
    @computer = Computer.new(a, b, c, instructions)
  end

  def solution_one
    "<#{@computer.tap(&:run).formatted_output}>"
  end

  def solution_two
    return 0 unless mode == :real
    i = 1
    b = @computer.registers[:B]
    c = @computer.registers[:C]
    instructions = @computer.instructions.flatten.join(",")

    # a = 35184372088832

    a = 1623933971000000

    while (output = Computer.new(a, b, c, instructions).tap(&:run).formatted_output) != instructions
      puts "#{a} - #{instructions} - #{output}" if (instructions.chars.last(13) == output.chars.last(13))
      a += 1
      # a = i * 2024
    end

    a
  end
end

class Computer
  attr_accessor :registers, :instructions

  OPERATIONS = [:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv]

  def initialize(a, b, c, instructions)
    @registers = { A: a, B: b, C: c }
    @instructions = parse_instructions(instructions)
    @ip = 0
    @output = []
    @verbose = false
    @error = false
  end

  def parse_instructions(input)
    input.split(",").each_slice(2).collect { |opcode, operand| [opcode.to_i, operand.to_i] }
  end

  def advance
    @ip += 1
  end

  def log(s)
    puts s if @verbose
  end

  def formatted_output
    @output.join(",")
  end

  def run
    while !@error && @ip < @instructions.length
      opcode, operand = @instructions[@ip]
      log "--- START"
      log "[#{@ip}] #{opcode} #{operand} - Reg: #{@registers} - Instr: #{@instructions} - Output: #{@output}"
      execute(opcode, operand)
      log "[#{@ip}] #{opcode} #{operand} - Reg: #{@registers} - Instr: #{@instructions} - Output: #{@output}"
      log "--- END"
      log ""
      advance unless OPERATIONS[opcode] == :jnz
    end
  end

  def execute(opcode, operand)
    send(OPERATIONS[opcode], operand)
  end

  def adv(operand)
    dv(:A, operand)
  end

  def bxl(operand)
    register_b = registers[:B]
    registers[:B] = register_b ^ operand
  end

  def bst(operand)
    registers[:B] = combo(operand) % 8
  end

  def jnz(operand)
    if registers[:A] != 0
      @ip = operand
    else
      advance
    end
  end

  def bxc(operand)
    register_b = registers[:B]
    register_c = registers[:C]
    registers[:B] = register_b ^ register_c
  end

  def out(operand)
    result = combo(operand) % 8
    @error = true if result > 6
    @output << result
  end

  def bdv(operand)
    dv(:B, operand)
  end

  def cdv(operand)
    dv(:C, operand)
  end

  def dv(register, operand)
    numerator = registers[:A]
    denominator = 2 ** combo(operand)
    result = (numerator.to_f / denominator).floor
    registers[register] = result
  end

  def combo(operand)
    return operand if [0, 1, 2, 3].include? operand
    return registers[:A] if operand == 4
    return registers[:B] if operand == 5
    return registers[:C] if operand == 6
    raise
  end
end

Computer.new(1, 2, 9, "2,6").run
Computer.new(10, 2, 9, "5,0,5,1,5,4").run

Day17.new.solve
