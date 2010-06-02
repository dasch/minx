
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'

def generate(range, cout)
  Minx.spawn { range.each {|i| cout.write(i) } }
end

def printer(cin)
  Minx.spawn { cin.each {|i| puts i } }
end

def worker(cin, cout)
  Minx.spawn do
    # Fetch the first prime number.
    prime = cin.read

    # Pass it on.
    cout.write(prime)

    # construct a child process.
    chan = Minx.channel

    worker(chan, cout)

    cin.each do |new_prime|
      if new_prime % prime != 0
        chan.write(new_prime) 
      end
    end
  end
end

N = ARGV[0] ? Integer(ARGV[0]) : 2000

JOBS    = Minx.channel
RESULTS = Minx.channel

printer(RESULTS)
worker(JOBS, RESULTS)

Minx.join(generate(2..N, JOBS))
