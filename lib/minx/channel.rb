
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
      @writers << Fiber.current

      if @readers.empty?
        reader = SCHEDULER.main while reader.nil?
      else
        reader = @readers.shift

        until reader.alive?
          reader = @readers.shift
          return write(message) if reader.nil?
        end

        reader.transfer(Fiber.current)

        SCHEDULER.enqueue(Fiber.current)
      end

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
    # block, only resuming when a write occurs.
    #
    # @return a message
    def read
      if @writers.empty?
        @readers << Fiber.current

        SCHEDULER.main while @writers.empty?

        writer = @writers.shift
        message = writer.transfer
      else
        writer = @writers.shift

        until writer.alive?
          writer = @writers.shift
          return read if writer.nil?
        end

        message = writer.transfer(Fiber.current)
        SCHEDULER.enqueue(Fiber.current)
        writer.transfer
      end

      return message
    end

    def read_async(callback)
      @readers << callback
    end

    def write_async(callback)
      @writers << callback
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

    def writable?
      return !@readers.empty?
    end

    private

    def debug(method, message)
      return unless Minx.debug?

      pid = Fiber.current.object_id.to_s(16)
      puts "[#{pid}] ##{method} - #{message}"
    end
  end
end
