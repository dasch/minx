
require 'fiber'

Minx = Module.new

require 'minx/channel'
require 'minx/process'

module Minx
  # Spawn a new process.
  def self.spawn(&block)
    Process.new(&block).spawn
  end
end
