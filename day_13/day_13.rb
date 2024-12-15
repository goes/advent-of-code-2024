require_relative "../day.rb"

class Day13 < Day
  def initialize
    super(13)
  end

  def reset
    @claw_machines = []
  end

  def parse_input
    lines = read_lines
    @claw_machines = read_lines.each_slice(4).collect { |chunk| ClawMachine.from_lines(chunk) }
  end

  def solution_one
    @claw_machines.sum(&:cheap_route_cost)
  end

  def solution_two
    @claw_machines.sum(&:cheap_route_cost_two)
  end
end

class ClawMachine
  attr_accessor :button_a, :button_b, :prize

  def self.from_lines(lines)
    a = Button.from_line(lines.detect { |l| /Button A/.match? l }, 3)
    b = Button.from_line(lines.detect { |l| /Button B/.match? l }, 1)
    prize_x = lines.detect { |l| /Prize/.match? l }.split(" ")[1].split("=").last.to_i
    prize_y = lines.detect { |l| /Prize/.match? l }.split(" ")[2].split("=").last.to_i
    self.new(a, b, Prize.new(prize_x, prize_y))
  end

  def initialize(button_a, button_b, prize)
    @prize = prize
    @button_a = button_a
    @button_b = button_b
  end

  def prize_two
    @prize.add_offset 10000000000000
  end

  def cheap_route_cost
    max_a = button_a.max_pushes_for(@prize)
    max_b = button_b.max_pushes_for(@prize)

    matches = (0..max_a).to_a.product((0..max_b).to_a).select { |a| self.prize == button_a.push(a.first) + button_b.push(a.last) }
    return 0 if matches.empty?

    matches.collect { |a| price(a.first, a.last) }.min
  end

  def cheap_route_cost_two
    pushes_b = (button_a.dx * prize_two.y - button_a.dy * prize_two.x) * 1.0 / (button_a.dx * button_b.dy - button_b.dx * button_a.dy)
    pushes_a = (prize_two.x - pushes_b * button_b.dx) * 1.0 / button_a.dx
    price(pushes_a, pushes_b)
  end

  81081081161 * 94 + 108108108148 * 22

  def price(pushes_a, pushes_b)
    return 0 unless pushes_a.to_i == pushes_a
    return 0 unless pushes_b.to_i == pushes_b
    pushes_a * button_a.cost + pushes_b * button_b.cost
  end
end

class Button
  attr_accessor :dx, :dy, :cost

  def self.from_line(line, cost)
    dx = line.split(" ")[2].split("+").last.to_i
    dy = line.split(" ")[3].split("+").last.to_i
    self.new(dx, dy, cost)
  end

  def initialize(dx, dy, cost)
    @dx = dx
    @dy = dy
    @cost = cost
  end

  def push(i)
    Prize.new(dx * i, @dy * i)
  end

  def max_pushes_for(prize)
    [prize.x / @dx, prize.y / @dy].min
  end
end

class Prize
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def add_offset(i)
    Prize.new(@x + i, @y + i)
  end

  def +(prize)
    Prize.new(@x + prize.x, @y + prize.y)
  end

  def *(i)
    Prize.new(@x * i, @y * i)
  end

  def ==(prize)
    x == prize.x && y == prize.y
  end
end

Day13.new.solve
