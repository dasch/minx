
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

def sum(input, output)
  Minx.spawn do
    sum = 0
    input.each do |i|
      break if i.nil?
      sum += i
    end
    output.write(sum)
  end
end

def worker(output)
  Minx.spawn do
    10.times { output.write(5) }
  end
end

values = Minx.channel
result = Minx.channel

sum(values, result)

Minx.spawn do
  workers = Array.new(10) { worker(values) }
  Minx.join(*workers)
  values.write(nil)
end

puts result.read
