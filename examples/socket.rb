
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'minx/io'
require 'socket'

include ::Socket::Constants

sockaddr = Socket.sockaddr_in(80, 'www.eb.dk')

Minx.debug = true

p = Minx.spawn do
  socket = Minx::Socket.new(AF_INET, SOCK_STREAM, 0)

  puts "Connecting..."
  socket.connect(sockaddr)

  puts "Writing..."
  str = 'GET / HTTP/1.0\r\n\r\n' + "XXX" * 5000

  written = 0
  until written == str.length
    written += socket.write(str[written..-1])
    puts "Wrote #{written} bytes"
  end

  puts "Reading..."
  puts socket.read(1024)

  puts "Done."
end

Minx.join(p)
