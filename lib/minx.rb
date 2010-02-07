
require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'

module Minx
  # Spawn a new process.
  #
  # @return [Process] a new process
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
  # The calling process will be resumed at a later point.
  def self.yield(*args)
    Fiber.yield(*args)
  end

  # Wait for the processes to yield execution.
  #
  # @return [nil]
  def self.join(*processes)
    processes.each do |process|
      process.resume
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
  # @return the first message received from any of the channels
  def self.select(*choices)
    options = choices.last.is_a?(Hash) ? choices.pop : {}

    # If a choice is readable, just receive from that one.
    choices.each do |choice|
      return choice.receive if choice.readable?
    end

    # Return immediately if :skip => true
    return if options[:skip]

    # ... otherwise, wait for a channel to become readable.
    choices.each do |choice|
      choice.receive(:async => true)
    end
    Minx.yield
  end
end
