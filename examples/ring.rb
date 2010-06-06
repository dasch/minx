
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

# Number of rounds.
M = ARGV[0] ? Integer(ARGV[0]) : 1000

# Number of elements.
N = ARGV[1] ? Integer(ARGV[1]) : 64

def node(input, id)
  output = Minx.channel
  Minx.spawn do
    input.each {|i| output.write(i) }
  end
  return output
end

FIRST = Minx.channel

start = Time.now
LAST = (0...N).inject(FIRST) {|chan, id| node(chan, id) }
puts "Spawned #{N} processes in #{Time.now - start}s"

i = 0
start = Time.now
M.times do
  FIRST.write(i)
  LAST.read
end
puts " => #{Time.now - start}"
