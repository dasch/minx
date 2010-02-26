
module Minx
  class IO
    def initialize(io)
      @io = io
    end

    def readline
      # Yield until the IO object is ready for reading.
      Minx.yield until select([@io])

      @io.readline
    end
  end

  class File < IO
    def initialize(filename)
      super(::File.open(filename))
    end
  end
end
