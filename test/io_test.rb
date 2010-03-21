require 'helper'
require 'minx/io'

FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures/data')

class IOTest < Test::Unit::TestCase
  context "A blocking IO operation" do
    setup do
      @io = Minx::IO.new(File.open('/dev/zero'))
    end

    should "not complain about missing test methods" do
      assert true
    end

    should_eventually "yield to another process" do
      Minx.spawn { @io.readline; assert false }
      assert true
    end
  end
end
