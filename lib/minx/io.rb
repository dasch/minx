
module Minx
  class IO
    def initialize(io)
      @io = io
    end

    def readline
      @io.readline
    end

    def write(str)
      @io.write(str)
    end

    def read(buffer_length)
      @io.read_nonblock(buffer_length)
    rescue Errno::EAGAIN
      Minx.yield
      retry
    end
  end

  class File < IO
    def initialize(filename)
      super(::File.open(filename))
    end
  end

  class Socket < IO
    def initialize(*args)
      require 'socket'

      @socket = ::Socket::Socket.new(*args)
      super(@socket)
    end

    def connect(sockaddr)
      @socket.connect_nonblock(sockaddr)
    rescue Errno::EINPROGRESS
      Minx.yield until ::IO.select([], [@socket], nil, 0)

      @socket.connect_nonblock(sockaddr)
    end
  end
end
