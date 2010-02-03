
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
  end
end
