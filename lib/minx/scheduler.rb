
module Minx
  class Scheduler
    def initialize
      @queue = []
      @main = Fiber.new do
        until @queue.empty?
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
      raise unless Minx.root?
      @main.transfer
    end
  end
end
