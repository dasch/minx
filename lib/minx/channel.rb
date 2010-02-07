
module Minx
  # A Channel is used to transmit messages between processes in a synchronized
  # manner.
  class Channel
    def initialize
      @readers = []
      @writers = []
    end

    # Write a message to the channel.
    #
    # If no readers are waiting, the calling process will block until one comes
    # along.
    #
    # @param message the message to be transmitted
    # @return [nil]
    def send(message)
      if @readers.empty?
        @writers << Fiber.current

        # Yield control
        Minx.yield

        # Yield a message back to a reader.
        Minx.yield(message)
      else
        @readers.shift.resume(message)
      end

      return nil
    end

    # Read a message off the channel.
    #
    # If no messages have been written to the channel, the calling process will
    # block, only resuming when a write occurs.
    #
    # @return a message
    def receive
      if @writers.empty?
        @readers << Fiber.current
        Minx.yield
      else
        @writers.shift.resume
      end
    end

    # Enumerate over the messages sent to the channel.
    #
    # @example Iterating over channel messages
    #   chan.each do |message|
    #     puts "Got #{message}!"
    #   end
    #
    # @yield [message]
    def each
      yield receive while true
    end

    # Returns whether there are any processes waiting to write.
    #
    # @return +true+ if you can receive a message from the channel
    def readable?
      return !@writers.empty?
    end
  end
end
