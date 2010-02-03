
require 'benchmark'

$:.unshift(File.dirname(__FILE__) + "/../lib/")

require 'minx'


# Number of processes.
N = 10000

# Number of rounds.
M = 10

channels = (0...N).map { Minx::Channel.new }
processes = (0...N).each do |i|
  Minx.spawn do
    M.times do
      value = channels[i].receive
      channels[(i + 1) % N].send(value + 1)
    end
  end
end

Benchmark.bmbm do |bm|
  bm.report("Sending a value #{M} times around a #{N}-length ring") do
    Minx.spawn do
      channels[0].send(0)
    end
  end
end
