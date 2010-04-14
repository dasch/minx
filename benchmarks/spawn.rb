
require 'benchmark'

$:.unshift(File.dirname(__FILE__) + "/../lib/")

require 'minx'

N = ARGV[0] ? Integer(ARGV[0]) : 100000

Benchmark.bmbm do |bm|
  bm.report("Spawning #{N} processes") do
    N.times { Minx.spawn { Minx.yield } }
  end
end
