
require 'fiber'

N = ARGV[0] ? Integer(ARGV[0]) : 2000

PRINTER = Fiber.new do |i|
  while true
    #puts i
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

start = Time.now
(2..N).each do |i|
  WORKER.resume(i)
end
puts (Time.now - start).ceil
