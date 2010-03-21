
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'minx/io'
require 'socket'

include ::Socket::Constants

Minx.debug = true

p = Minx.spawn do
  socket = Socket.new(AF_INET, SOCK_STREAM, 0)

  channel = Minx::SocketChannel.new(socket)

  puts "Connecting..."
  channel.connect('www.eb.dk', :port => 80)

  puts "Writing..."
  channel.write('GET / HTTP/1.0\r\n\r\n')

  puts "Reading..."
  channel.each {|line| puts line }

  puts "Done."
  channel.disconnect
end

Minx.join(p)
