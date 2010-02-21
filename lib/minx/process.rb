
module Minx
  ProcessError = Class.new(Exception)

  class Process
    # Initialize a new process.
    #
    # The process is *not* spawned when instantiated; you'll need to call
    # {#spawn} manually. Call {Minx.spawn} to immediately spawn a new process.
    #
    # @example Creating a new process
    #   p = Minx::Process.new { 1 + 1 }
    #   p.spawn
    #
    # @raise [ArgumentError] unless a block is given
    # @see Minx.spawn
    def initialize(&block)
      raise ArgumentError unless block_given?
      @fiber = Fiber.new { block.call }
    end

    # Spawn the process.
    #
    # The process will immediately take over execution, and the current
    # fiber will yield.
    #
    # @raise [ProcessError] if the process has already been spawned
    def spawn
      __resume__
    end

    # Resume the process.
    #
    # This yields execution to the process.
    #
    # @private
    # @raise [ProcessError] if the process has finished
    def __resume__
      raise ProcessError if finished?
      @fiber.resume
      self
    end

    # Whether the process has finished execution.
    #
    # @return true if the process is no longer active
    def finished?
      !@fiber.alive?
    end
  end
end
