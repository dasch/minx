
module Minx
  ProcessError = Class.new(Exception)

  # A process is the core concurrency primitive in Minx.
  #
  # Processes run concurrently and independently. In order to synchronize and
  # organize processes you need to use _channels_ -- these synchronously
  # transmit messages between two processes, making them ideal for
  # communication and synchronization.
  #
  # Oftentimes, you need not work directly with the Process objects, but
  # can use the methods on the {Minx} module directly, such as {Minx.spawn},
  # {Minx.yield}, and {Minx.join}.
  #
  # @see Channel
  # @see Minx.spawn
  # @see Minx.yield
  # @see Minx.join
  class Process
    # Initialize a new process.
    #
    # The process is *not* spawned when instantiated; you'll need to call
    # {#spawn} manually. Call {Minx.spawn} to immediately spawn a new process.
    #
    # @example Creating a new process
    #   p = Minx::Process.new { 1 + 1 }
    #   p.spawn
    #
    # @raise [ArgumentError] unless a block is given
    # @see Minx.spawn
    def initialize(&block)
      raise ArgumentError unless block_given?

      @supervisors = []
      @block = block
    end

    # Spawn the process.
    #
    # The process will immediately take over execution, and the current
    # fiber will yield.
    #
    # @raise [ProcessError] if the process has already been spawned
    def spawn
      raise ProcessError if defined?(@fiber)

      @fiber = Fiber.new do
        begin
          @block.call
        rescue Exception => e
          if @supervisors.empty?
            $stderr.puts("#{e.class}: #{e.message}")
            $stderr.puts(e.backtrace)
            exit(-1) if Minx.abort_on_exception
          else
            @supervisors.each {|s| s.resume(e, self) }
          end
        end
      end

      @fiber.resume

      return self
    end

    # Whether the process has finished execution.
    #
    # @return +true+ if the process has terminated, +false+ otherwise
    def finished?
      !@fiber.alive?
    end

    def supervise
      @supervisors << Fiber.current
    end

    class << self
      # The currently running process.
      attr_accessor :current
    end
  end
end
