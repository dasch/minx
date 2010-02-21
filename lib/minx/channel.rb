
module Minx
  # A Channel is used to transmit messages between processes in a synchronized
  # manner.
  class Channel
    # Create a new channel.
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
        Fiber.yield(message)
      else
        @readers.shift.resume(message)
      end

      return nil
    end

    alias :<< :send

    # Read a message off the channel.
    #
    # If no messages have been written to the channel, the calling process will
    # block, only resuming when a write occurs. This behavior can be suppressed
    # by calling +receive+ with <code>:async => true</code>, in which case the
    # call will return immediately; the next time the calling process yields,
    # it may be resumed with a message from the channel.
    #
    # @option options [Boolean] :async (false) whether or not to block
    # @return a message
    def receive(options = {})
      if @writers.empty?
        @readers << Fiber.current
        Minx.yield unless options[:async]
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

    # Whether there are any processes waiting to write.
    #
    # If the channel is readable, the current process will not block when
    # calling {#receive}.
    #
    # @return +true+ if you can receive a message without blocking
    def readable?
      return !@writers.empty?
    end
  end
end
