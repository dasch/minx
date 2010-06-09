
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'socket'

def worker(queue)
  Minx.spawn do
    queue.each do |client|
      next if client.nil?
      process_request(client)
    end
  end
end

def process_request(client)
  buffer = ""
  buffer_length = 1024

  puts "Processing request from #{client}"

  begin
    part = client.read_nonblock(buffer_length)

    break if part == "\r\n"

    buffer << part
  rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::EINTR
    Minx.yield
    retry
  end while true

  client.puts "200 OK HTTP/1.1"
  client.puts "Content-Type: text/plain"
  client.puts "\r\n"
  client.puts "Hello, World!\n"

  client.close
end

socket = TCPServer.open(8080)
queue = Minx.channel

5.times { worker(queue) }

while true
  begin
    client = socket.accept_nonblock
    queue.write(client)
  rescue Errno::EAGAIN
    Minx.yield until IO.select([socket], [], [], 0)
    retry
  end
end
