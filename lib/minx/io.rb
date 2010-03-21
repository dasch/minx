
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

    # Read at most +buffer_length+ bytes from the IO object.
    #
    # @param [Integer] buffer_length max number of bytes to read
    # @param [String] buffer buffer string
    # @return [String] the content that was read
    def read(buffer_length, buffer = nil)
      @io.read_nonblock(buffer_length, buffer)
    rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::EINTR
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
