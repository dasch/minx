
require 'helper'

class ChoiceTest < Test::Unit::TestCase
  context "A simple choice between two channels" do
    setup do
      @chan1 = Minx::Channel.new
      @chan2 = Minx::Channel.new
    end

    context "with a single writer" do
      setup do
        Minx.spawn { @chan2.send(42) }
      end

      should "receive from the channel with a writer" do
        Minx.spawn do
          assert_equal 42, Minx.select(@chan1, @chan2)
        end
      end
    end

    context "with writers on both channels" do
      setup do
        Minx.spawn { @chan1.send(666) }
        Minx.spawn { @chan2.send(42) }
      end

      should "receive from the first channel specified" do
        Minx.spawn do
          assert_equal 666, Minx.select(@chan1, @chan2)
        end
      end

      should "not receive from the second channel specified" do
        Minx.spawn do
          Minx.select(@chan1, @chan2)
          assert_equal 42, @chan2.receive
        end
      end
    end

    context "with no writers" do
      setup do
        Minx.spawn { @value = Minx.select(@chan1, @chan2) }
      end

      should "block until a writer comes along" do
        Minx.spawn { @chan1.send(42) }
        assert_equal 42, @value
      end

      should "also block until the second channel gets written to" do
        Minx.spawn { @chan2.send(666) }
        assert_equal 666, @value
      end
    end
  end
end
