require 'helper'

class ChannelTest < Test::Unit::TestCase
  context "A Channel" do
    setup do
      @channel = Minx.channel
      @data = []
      @p1 = Minx::Process.new { @channel.write(:foo) }
      @p2 = Minx::Process.new { @data << @channel.read }
    end

    context "with first a reader, then a writer" do
      setup do
        @p2.spawn
        @p1.spawn
      end

      should "be able to transmit a message" do
        assert_equal :foo, @data.first
      end
    end

    context "with first a writer, then a reader" do
      setup do
        @p1.spawn
        @p2.spawn
      end

      should "be able to transmit a message" do
        assert_equal :foo, @data.first
      end
    end

    should "write a message with #<<" do
      Minx.spawn { @channel << :bar }
      assert_equal :bar, @channel.read
    end

    should "iterate over messages on #each" do
      Minx.spawn { [:foo, :bar, :baz].each {|msg| @channel.write(msg) } }

      values = [:foo, :bar, :baz]
      Minx.spawn do
        @channel.each do |message|
          assert_equal values.shift, message
        end
      end
    end
  end

  context "A channel" do
    setup do
      @chan = Minx.channel
    end

    should "allow chained writing using #<<" do
      p1 = Minx.spawn { 1.upto(3) {|i| assert_equal(i, @chan.read) } }
      p2 = Minx.spawn { @chan << 1 << 2 << 3 }
    end
  end

  context "Forwarding between two channels" do
    should "not block" do
      input = Minx.channel
      output = Minx.channel

      Minx.spawn do
        input.each do |message|
          output.write(message)
        end
      end

      p1 = Minx.spawn do
        input << 1 << 2 << 3
      end

      p2 = Minx.spawn do
        assert_equal 1, output.read
        assert_equal 2, output.read
        assert_equal 3, output.read
      end

      Minx.join(p1, p2)
    end
  end
end
