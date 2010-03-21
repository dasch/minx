
module Minx
  class IOChannel
    def initialize(io)
      @io = io
    end

    def read
      @io.readline
    end

    def each
      yield read until @io.eof?
    end

    def write(message)
      @io.write(message)
    end

    def << message
      write(message)
      return self
    end

    private

    # Read at most +buffer_length+ bytes from the IO object.
    #
    # @param [Integer] buffer_length max number of bytes to read
    # @param [String] buffer buffer string
    # @return [String] the content that was read
    def __read(buffer_length, buffer = nil)
      @io.read_nonblock(buffer_length, buffer)
    rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::EINTR
      Minx.yield
      retry
    end
  end
end
