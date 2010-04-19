
unless defined?(Fiber)
  raise "You need to use Ruby 1.9 in order to use Minx"
end

require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'

module Minx
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
    Fiber.yield
  rescue FiberError => error
    raise ProcessError.new(error)
  end

  def self.block
    Process.current.blocked = true
    Fiber.yield
  ensure
    Process.current.blocked = false
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
    until processes.empty?
      # Purge finished processes.
      processes.delete_if {|p| p.finished? }

      # Resume all non-blocked processes.
      active = processes.inject(0) do |count, process|
        process.__resume__ unless process.blocked?
        count + 1
      end

      Fiber.yield rescue nil
    end

    return nil
  end

  # Select from a list of channels.
  #
  # The channels will be enumerated in order; the first one carrying a message
  # will be picked, and the message will be returned.
  #
  # If none of the channels are readable, the calling process will yield until
  # a channel is written to, unless <code>:skip => true</code> is passed as
  # an option, in which case the call will just return +nil+.
  #
  # @example Non-blocking select
  #   Minx.select(chan1, chan2, :skip => true)
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
    choices.each do |choice|
      choice.read(:async => true)
    end
    Minx.yield
  end
end
