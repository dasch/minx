
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

# Number of rounds.
M = ARGV[0] ? Integer(ARGV[0]) : 1001

# Number of elements.
N = ARGV[1] ? Integer(ARGV[1]) : 64

def node(input, id)
  output = Minx.channel
  Minx.spawn do
    input.each do |i|
      #puts "[#{id}] => #{message.inspect}"
      output.write(i + 1)
      #puts "[#{id}] DONE"
    end
  end
  return output
end

FIRST = Minx.channel

LAST = (0...N).inject(FIRST) {|chan, id| node(chan, id) }

i = 0

FIRST.write(i)

M.times do
  i = LAST.read
  FIRST.write(i)
end

puts "Result: #{i}"
