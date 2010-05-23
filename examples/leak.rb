
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

N = ARGV[0] ? Integer(ARGV[0]) : 100000

N.times { Minx.spawn { } }

GC.start

count = ObjectSpace.each_object(Minx::Process) { }

puts "Number of Process instances: #{count}"
