require 'helper'
require 'minx/utils'

class UtilitiesTest < Test::Unit::TestCase
  context "A Map process" do
    setup do
      @chan1 = Minx.channel
      @chan2 = Minx.channel
      @process = Minx.map(@chan1, @chan2) {|message| message * 2 }
    end

    should "map messages from the input to the output channel" do
      Minx.spawn { @chan1 << 7 }
      assert_equal 14, @chan2.read
    end
  end
end
