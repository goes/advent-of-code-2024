require_relative "../day.rb"

class Day09 < Day
  def initialize
    super(9)
  end

  def reset
    @diskmap = nil
  end

  def parse_input
    @diskmap = DiskMap.new(read_lines.first)
  end

  def solution_one
    @diskmap.checksum_one
  end

  def solution_two
    @diskmap.checksum_two
  end
end

class DiskMap
  attr_accessor :blocks

  def initialize(line)
    @input = line.chars.collect(&:to_i)
    initialize_blocks
  end

  def checksum_one
    defragmented = @blocks.dup
    up, down = 0, @blocks.size - 1

    while up < down
      unless defragmented[up]
        while defragmented[down].nil?
          down -= 1
        end
        defragmented[up] = defragmented[down]
        defragmented[down] = nil
      end
      up += 1
    end

    defragmented.compact.each_with_index.sum { |val, idx| val * idx }
  end

  def checksum_two
    intervals_to_reposition = @intervals.reverse.select(&:has_value?)

    intervals_to_reposition.each do |interval|
      match = @intervals.detect { |itr| itr.accomodates?(interval) }

      next unless match
      next if match.position > interval.position

      combined = match.combine(interval)
      index = @intervals.index(match)

      combined.reverse.each { |i| @intervals.insert(index, i) }

      @intervals.delete(match)
      @intervals.detect { |i| i == interval }.clear
    end

    @intervals.inject([]) do |arr, interval|
      interval.length.times { arr << interval.value }
      arr
    end.each_with_index.sum { |val, idx| (val || 0) * idx }
  end

  def initialize_blocks
    id, file = 0, true

    position = 0
    blocks, intervals = [], []
    @input.each_with_index do |nr, idx|
      file_nr = file ? id : nil
      nr.times { blocks << file_nr }

      intervals << Interval.new(file_nr, position, nr)
      position += nr

      id += 1 unless file
      file = !file
    end
    @blocks = blocks
    @intervals = intervals
  end
end

class Interval
  attr_accessor :value, :length, :position

  def initialize(val, start, cnt)
    @value, @position, @length = val, start, cnt
  end

  def accomodates?(interval)
    return false unless @value.nil?
    return false if interval.value.nil?
    interval.length <= length
  end

  def combine(interval)
    combined = [self.class.new(interval.value, position, interval.length)]
    combined << self.class.new(value, position + interval.length, length - interval.length) if length - interval.length > 0

    combined
  end

  def has_value?
    !@value.nil?
  end

  def clear
    @value = 0
  end
end
