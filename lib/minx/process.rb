
module Minx
  class Process
    def initialize(&block)
      raise ArgumentError unless block_given?
      @fiber = Fiber.new { block.call }
    end

    # Spawn the process.
    #
    # The process will immediately take over execution, and the current
    # fiber will yield.
    def spawn
      @fiber.resume
    end

    # Resume the process.
    #
    # This yields execution to the process.
    def resume
      @fiber.resume
    end

    # Whether the process has finished execution.
    #
    # @return true if the process is no longer active
    def finished?
      !@fiber.alive?
    end
  end
end
