
unless defined?(Fiber)
  raise LoadError.new("You need to use Ruby 1.9 in order to use Minx")
end

require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'
require 'minx/scheduler'

module Minx
  # The root fiber.
  #
  # @private
  ROOT = Fiber.current
  SCHEDULER = Scheduler.new

  # Whether this is the root process.
  #
  # @private
  def self.root?
    ROOT == Fiber.current
  end

  # Set whether or not to enable debugging output.
  #
  # Debugging information will be written to <code>$stderr</code>.
  #
  # @return [nil]
  def self.debug=(debug)
    @debug = debug

    return nil
  end

  # Whether or not debugging is enabled.
  #
  # @return [Boolean] whether or not debugging is enabled
  # @see debug=
  def self.debug?
    @debug
  end

  # Spawn a new process.
  #
  # The spawned process will start immediately, taking over execution.
  #
  # @return [Process] a new process
  # @raise [ArgumentError] unless a block is given
  # @see Process#spawn
  def self.spawn(&block)
    Process.new(&block).spawn
  end

  # Create a new channel.
  #
  # @return [Channel] a new channel
  def self.channel
    Channel.new
  end

  # Yield control to another process.
  #
  # The current process will be resumed at a later point.
  #
  # @return [nil]
  def self.yield
    SCHEDULER.yield
  end

  # Wait for the specified processes to finish.
  #
  # The current process will be resumed after all the specified processes
  # have terminated.
  #
  # @example Waiting for a pair of processes
  #   p1 = Minx.spawn { @foo = chan1.read }
  #   p2 = Minx.spawn { @bar = chan2.read }
  #
  #   Minx.join(p1, p2)
  #
  #   # Both @foo and @bar are available now.
  #   puts @foo, @bar
  #
  # @return [nil]
  def self.join(*processes)
    Minx.yield until processes.all? {|p| p.finished? }
  end

  # Write a message simultaneously to one of a set channels.
  #
  # The first channel that is ready to consume a message will
  # be chosen. If more than one is ready, the first specified
  # in the argument list is chosen.
  #
  # @param message the message to be transmitted
  # @return [nil]
  def self.push(message, *choices)
    choices.each do |channel|
      return channel.write(message) if channel.writable?
    end

    current = Fiber.current
    callback = Fiber.new do |reader|
      Fiber.yield(message)
      SCHEDULER.enqueue(current)
    end

    choices.each do |choice|
      choice.write_async(callback)
    end

    Fiber.yield
  end

  def self.write(*choices)
    # Allows for both :msg => channel as well as [:msg, channel].
    if choices.size == 1 && choices.first.is_a?(Hash)
      choices = choices.first
    end

    processes = choices.map do |message, channels|
      Minx.spawn { Minx.push(message, *channels) }
    end

    Minx.join(*processes)
  end

  # Simultaneously read from multiple channels.
  #
  # The channels will be enumerated in order; the first one carrying a message
  # will be picked, and the message will be returned.
  #
  # If none of the channels are readable, the calling process will yield until
  # a channel is written to, unless <code>:skip => true</code> is passed as
  # an option, in which case the call will just return +nil+.
  #
  # @example Non-blocking select
  #   Minx.read(chan1, chan2, :skip => true)
  #
  # @param choices [Channel] the channels to be selected among
  # @return the first message read from any of the channels
  def self.select(*choices)
    options = choices.last.is_a?(Hash) ? choices.pop : {}

    # If a choice is readable, just read from that one.
    choices.each do |choice|
      return choice.read if choice.readable?
    end

    # Return immediately if :skip => true
    return if options[:skip]

    # ... otherwise, wait for a channel to become readable.
    current = Fiber.current

    callback = Fiber.new do |writer|
      message = writer.transfer(Fiber.current)
      current.resume(message)
    end

    choices.each do |choice|
      choice.read_async(callback)
    end

    Fiber.yield
  end

  def self.read(*channels)
    results = []

    i = -1
    ps = channels.map do |chan|
      i += 1
      Minx.spawn { results[i] = chan.read }
    end

    Minx.join(*ps)

    return results
  end

  def self.supervise(*processes)
    processes.each {|p| p.supervise }

    until processes.all? {|p| p.finished? }
      if root?
        yield SCHEDULER.main
      else
        yield Fiber.yield
      end
    end
  end
end

END { Minx::SCHEDULER.main }
