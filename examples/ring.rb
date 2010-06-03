
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'benchmark'

# Number of rounds.
M = ARGV[0] ? Integer(ARGV[0]) : 1000

# Number of elements.
N = ARGV[1] ? Integer(ARGV[1]) : 64

def node(input, id)
  output = Minx.channel
  Minx.spawn do
    input.each {|i| output.write(i.succ) }
  end
  return output
end

FIRST = Minx.channel

LAST = (0...N).inject(FIRST) {|chan, id| node(chan, id) }

Benchmark.bm do |bm|
  bm.report("RING") do
    i = 0
    M.times do
      FIRST.write(i)
      i = LAST.read
    end
  end
end
