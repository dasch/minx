
require 'fiber'

# Number of rounds.
M = ARGV[0] ? Integer(ARGV[0]) : 10

# Number of elements.
N = ARGV[1] ? Integer(ARGV[1]) : 64

def node(output, id)
  Fiber.new do |i|
    while true
      i = output.transfer(i.succ)
    end
  end
end

LAST = Fiber.new do |i|
  M.times do
    puts i
    i = FIRST.transfer(i.succ)
  end
  i = Fiber.yield(i)
end

FIRST = (0...N).inject(LAST) {|chan, id| node(chan, id) }

i = 0
M.times do
  FIRST.transfer(i)
  i = LAST.resume
end

puts i
