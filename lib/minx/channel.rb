
module Minx
  ChannelError = Class.new(Exception)

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
    # @raise [ChannelError] when trying to write while asynchronously reading
    # @return [nil]
    def write(message)
      if @readers.empty?
        debug :write, "no readers, waiting"
        @writers << Fiber.current

        debug :write, "got woken up"
        reader = Fiber.yield
      else
        debug :write, "reader waiting, waking him up"
        reader = @readers.shift
      end

      SCHEDULER.enqueue(Fiber.current)

      debug :write, "transferring message #{message.inspect}"
      reader.transfer(message)

      return nil
    end

    # Write a message to the channel.
    #
    # Exactly the same as calling {#write}, except that the channel itself
    # is returned, allowing for chained calls, e.g.
    #
    #   chan << 1 << 2 << 3
    #
    # @see #write
    # @param message the message to be transmitted
    # @return [Channel] the channel
    def << message
      write(message)
      return self
    end

    # Read a message off the channel.
    #
    # If no messages have been written to the channel, the calling process will
    # block, only resuming when a write occurs. This behavior can be suppressed
    # by calling +read+ with <code>:async => true</code>, in which case the
    # call will return immediately; the next time the calling process yields,
    # it may be resumed with a message from the channel.
    #
    # @option options [Boolean] :async (false) whether or not to block
    # @return a message
    def read
      if @writers.empty?
        debug :read, "no writers, waiting"
        @readers << Fiber.current
        message = Fiber.yield
      else
        debug :read, "writer waiting, waking him up"
        writer = @writers.shift
        message = writer.transfer(Fiber.current)
      end

      debug :read, "received #{message.inspect}"

      return message
    end

    # Enumerate over the messages sent to the channel.
    #
    # @example Iterating over channel messages
    #   chan.each do |message|
    #     puts "Got #{message}!"
    #   end
    #
    # @yield [message]
    # @return [nil]
    def each
      yield read while true
    end

    # Whether there are any processes waiting to write.
    #
    # If the channel is readable, the current process will not block when
    # calling {#read}.
    #
    # @return +true+ if you can read a message without blocking
    def readable?
      return !@writers.empty?
    end

    private

    def debug(method, message)
      return unless Minx.debug?

      pid = Fiber.current.object_id.to_s(16)
      puts "[#{pid}] ##{method} - message"
    end
  end
end
