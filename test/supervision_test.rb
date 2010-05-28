require 'helper'

class SupervisionTest < Test::Unit::TestCase
  context "A supervised process" do
    should "notificy any supervisor in the case of failure" do
      @p = Minx.spawn { Minx.yield; raise Exception.new("This is a TEST") }
      @s = Minx.spawn do
        Minx.supervise(@p) {|e| @e = e }
      end

      Minx.join(@p)

      assert_equal Exception, @e.class
      assert_equal "This is a TEST", @e.message
      assert @p.finished?
    end
  end

  context "A supervisor process" do
    should "continue after the supervised processes have finished" do
      @p = Minx.spawn { Minx.yield }

      Minx.supervise(@p) { }
    end
  end
end
