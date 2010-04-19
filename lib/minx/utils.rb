
module Minx
  class << self

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

  end
end
