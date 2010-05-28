
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

def map
  output = Minx.channel
  Minx.spawn { loop { output.write(rand(100)) } }
  return output
end

def reduce(*inputs, output)
  Minx.spawn do
    loop do
      sum = 0
      10.times { sum += Minx.select(*inputs) }
      output.write(sum)
    end
  end
end

inputs = (0...10).map { map }
output = Minx.channel

reduce(*inputs, output)

puts output.read
puts output.read
