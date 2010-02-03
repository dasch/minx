
class Minx::Channel
  def initialize
    @readers = []
    @writers = []
  end

  # Write a message to the channel.
  #
  # If no readers are waiting, the calling process will block until one comes
  # along.
  def send(message)
    @readers.shift.resume(message)
  end

  # Read a message off the channel.
  #
  # If no messages have been written to the channel, the calling process will
  # block, only resuming when a write occurs.
  def receive
    @readers << Fiber.current
    Fiber.yield
  end
end
