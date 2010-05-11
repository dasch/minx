
module Minx
  class Scheduler
    def initialize
      @queue = []
      @main = Fiber.new do
        while true
          Fiber.yield while @queue.empty?
          fiber = @queue.shift
          fiber.transfer if fiber.alive?
        end
      end
    end

    def yield
      @queue << Fiber.current
      if Minx.root?
        @main.transfer
      else
        Fiber.yield
      end
    end

    def main
      @main.transfer
    end

    def enqueue(fiber)
      @queue << fiber
    end

    def switch(fiber)
      @queue << Fiber.current
      fiber.resume
    end
  end
end
