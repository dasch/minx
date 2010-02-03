
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
        Fiber.yield

        # Yield a message back to a reader.
        Fiber.yield(message)
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
        Fiber.yield
      else
        @writers.shift.resume
      end
    end
  end
end
