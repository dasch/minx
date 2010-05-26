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

  context "A Filter process" do
    setup do
      @chan1 = Minx.channel
      @chan2 = Minx.channel

      # Drop odd messages.
      @process = Minx.filter(@chan1, @chan2) {|i| i % 2 == 0 }
    end

    should "filter messages" do
      Minx.spawn do
        @chan1 << 7 << 4 << 18
      end

      assert_equal 4,  @chan2.read
      assert_equal 18, @chan2.read
    end
  end

  context "A producer process" do
    should "produce values" do
      fib = Minx.producer do |chan|
        i, j = 0, 1
        loop do
          chan << i
          i, j = j, i + j
        end
      end

      [0, 1, 1, 2, 3, 5, 8, 13].each do |i|
        assert_equal i, fib.read
      end
    end
  end
end
