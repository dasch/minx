require 'helper'
require 'minx/io'

class IOTest < Test::Unit::TestCase
  context "A blocking IO operation" do
    setup do
      @io = Minx::IOChannel.new(File.open('/dev/zero'))
    end

    should "not complain about missing test methods" do
      assert true
    end

    should_eventually "yield to another process" do
      Minx.spawn { @io.read; assert false }
      assert true
    end
  end
end
