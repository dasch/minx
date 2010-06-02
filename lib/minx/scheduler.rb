
module Minx
  class Scheduler
    def initialize
      @queue = []
      @main = Fiber.new do
        while true
          until @queue.empty?
            fiber = @queue.shift
            fiber.transfer if fiber.alive?
          end
          Fiber.yield
        end
      end
    end

    def yield
      if Minx.root?
        unless @queue.empty?
          fiber = @queue.shift
          fiber.transfer if fiber.alive?
        end
      else
        @queue << Fiber.current
        Fiber.yield
      end
    end

    def main
      if Minx.root?
        @main.transfer
      else
        Fiber.yield
      end
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
