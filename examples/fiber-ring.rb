require 'fiber'

# Number of rounds.
M = ARGV[0] ? Integer(ARGV[0]) : 10

# Number of elements.
N = ARGV[1] ? Integer(ARGV[1]) : 64

start = Time.now

FIRST = (1...N).inject(Fiber.current) do |output, id|
  f = Fiber.new do
    i = Fiber.yield
    while true
      i = output.transfer(i.succ)
    end
  end
  f.resume
  f
end

puts "Spawned #{N} fibers in #{Time.now - start}s"

puts "==== START ===="
start = Time.now
i = 0
M.times do
  i = FIRST.transfer(i.succ)
end
puts " == #{i}"

puts " => #{Time.now - start}s"
