
module Minx
  ProcessError = Class.new(Exception)

  class Process
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
      resume
    end

    # Resume the process.
    #
    # This yields execution to the process.
    #
    # @raise [ProcessError] if the process has finished
    def resume
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
