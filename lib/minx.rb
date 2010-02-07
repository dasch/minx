
require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'

module Minx
  # Spawn a new process.
  def self.spawn(&block)
    Process.new(&block).spawn
  end

  # Yield control to another process.
  #
  # The calling process will be resumed at a later point.
  def self.yield(*args)
    Fiber.yield(*args)
  end

  # Select from a list of channels.
  #
  # The channels will be enumerated in order; the first one carrying a message
  # will be picked, and the message will be returned.
  #
  # If none of the channels are readable, the calling process will yield until
  # a channel is written to.
  #
  # @param choices [Channel] the channels to be selected among
  # @return the first message received from any of the channels
  def self.select(*choices)
    # If a choice is readable, just receive from that one.
    choices.each do |choice|
      return choice.receive if choice.readable?
    end

    # ... otherwise, wait for one to become readable.
    choices.each do |choice|
      choice.receive(:async => true)
    end
    Minx.yield
  end
end
