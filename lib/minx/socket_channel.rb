
require 'minx/io_channel'
require 'socket'

module Minx
  class SocketChannel < IOChannel
    def initialize(socket)
      @socket = socket
      super(@socket)
    end

    # Connect to +host+ on the port specified in the <code>:port</code>
    # option.
    #
    # @param [String] host the name of the host that is to be used
    # @param [Hash] options socket options
    # @option options [Integer] :port the remote port that is to be used
    # @raise [ArgumentError] if no port is specified in the options
    def connect(host, options = {})
      raise ArgumentError.new("Missing option: port") if options[:port].nil?

      port = options[:port]

      sockaddr = Socket.sockaddr_in(port, host)

      @socket.connect_nonblock(sockaddr)
    rescue Errno::EINPROGRESS
      Minx.yield until ::IO.select([], [@socket], nil, 0)

      @socket.connect_nonblock(sockaddr)
    end

    # Close the connection.
    def disconnect
      @socket.close
    end
  end
end
