
module Minx
  class IO
    def initialize(io)
      @io = io
    end

    def readline
      @io.readline
    end
  end

  class File < IO
    def initialize(filename)
      super(::File.open(filename))
    end
  end
end
