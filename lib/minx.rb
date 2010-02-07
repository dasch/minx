
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
    choices.each do |choice|
      return choice.receive if choice.readable?
    end
  end
end
