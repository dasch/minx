
# A Channel is used to transmit messages between processes in a synchronized
# manner.
class Minx::Channel
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
    @readers.shift.resume(message)
    return nil
  end

  # Read a message off the channel.
  #
  # If no messages have been written to the channel, the calling process will
  # block, only resuming when a write occurs.
  #
  # @return a message
  def receive
    @readers << Fiber.current
    Fiber.yield
  end
end
