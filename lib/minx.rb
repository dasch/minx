
require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'

module Minx
  # Spawn a new process.
  def self.spawn(&block)
    Process.new(&block).spawn
  end

  # Yields control.
  def self.yield(*args)
    Fiber.yield(*args)
  end

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
