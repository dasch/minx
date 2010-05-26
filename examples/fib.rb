
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

def fibonacci
  fib = Minx.channel

  Minx.spawn do
    i, j = 0, 1
    loop do
      fib.write(i)
      i, j = j, i + j
    end
  end

  return fib
end

fib = fibonacci

10.times { puts fib.read }
