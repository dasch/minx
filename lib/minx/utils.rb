
module Minx
  module Utils

    # Map messages from +input+ to +output+.
    #
    # Provide a block that takes a single argument, and it will be called
    # with every message read from +input+. The result of the block will
    # be written to +output+.
    #
    #   # c1 and c2 are channels.
    #   double = Minx.map(c1, c2) {|i| i * 2 }
    #
    # @param [Channel] input input channel
    # @param [Channel] output output channel
    # @yieldparam message
    # @raise [ArgumentError] if no block is given
    # @return [Process] the mapping process
    def map(input, output)
      unless block_given?
        raise ArgumentError.new("Please provide a block argument")
      end

      Minx.spawn do
        input.each do |message|
          output.write(yield message)
        end
      end
    end

    # Filter messages from +input+.
    #
    # Yields messages read from +input+ to the block argument,
    # forwarding those for which the block returns +true+ to
    # the +output+ channel.
    #
    # @param [Channel] input input channel
    # @param [Channel] output output channel
    # @yieldparam message
    # @raise [ArgumentError] if no block is given
    # @return [Process] the filtering process
    def filter(input, output)
      unless block_given?
        raise ArgumentError.new("Please provide a block argument")
      end

      Minx.spawn do
        input.each do |message|
          if yield message
            output.write(message)
          end
        end
      end
    end

    # Spawn a producer process attached to a channel.
    #
    #   fib = Minx.producer do |chan|
    #     i, j = 0, 1
    #     loop do
    #       chan << i
    #       i, j = j, i + j
    #     end
    #   end
    #
    #   fib.read  #=> 0
    #   fib.read  #=> 1
    #   fib.read  #=> 1
    #   fib.read  #=> 2
    #
    # @yieldparam [Channel] channel the communication channel
    # @return [Channel] the channel being produced on.
    def producer(&block)
      chan = Minx.channel
      Minx.spawn { block.call(chan) }
      return chan
    end
  end

  extend Utils
end
