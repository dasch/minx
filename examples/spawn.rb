
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'benchmark'

N = ARGV[0] ? Integer(ARGV[0]) : 100000

puts "=== Spawning #{N} processes ==="

Benchmark.bm do |bm|
  bm.report("SPAWN") do
    N.times do
      Minx.spawn { }
    end
  end
end
