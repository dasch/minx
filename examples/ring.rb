
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

N = 1000
M = 5000

def node(input, id)
  output = Minx.channel
  Minx.spawn do
    input.each do |message|
      message += 1
      #puts "[#{id}] => #{message.inspect}"
      output.write(message)
      #puts "[#{id}] DONE"
    end
  end
  return output
end

FIRST = Minx.channel

LAST = (0...N).inject(FIRST) {|chan, i| node(chan, i) }

FIRST.write(0)

(M - 1).times do |i|
  #puts "==== ROUND #{i} ===="
  message = LAST.read
  FIRST.write(message)
end
