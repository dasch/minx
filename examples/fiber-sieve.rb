
require 'fiber'

PRINTER = Fiber.new do |i|
  while true
    puts i
    i = Fiber.yield
  end
end

def worker
  Fiber.new do |prime|
    PRINTER.resume(prime)

    w = worker

    while true
      i = Fiber.yield

      if i % prime != 0
        w.resume(i)
      end
    end
  end
end

WORKER = worker

(2..2000).each do |i|
  WORKER.resume(i)
end
