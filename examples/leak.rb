
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

N = ARGV[0] ? Integer(ARGV[0]) : 100000

N.times { Minx.spawn { Minx.channel.read } }

GC.start

processes = ObjectSpace.each_object(Minx::Process) { }
channels = ObjectSpace.each_object(Minx::Channel) { }

puts "Number of Process instances: #{processes}"
puts "Number of Channel instances: #{channels}"
