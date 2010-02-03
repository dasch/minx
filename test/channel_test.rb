require 'helper'

class ChannelTest < Test::Unit::TestCase
  context "A Channel" do
    setup do
      @channel = Minx::Channel.new
      @data = []
      @p1 = Minx::Process.new { @channel.send(:foo) }
      @p2 = Minx::Process.new { @data << @channel.receive }
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

    should "iterate over messages on #each" do
      Minx.spawn { [:foo, :bar, :baz].each {|msg| @channel.send(msg) } }

      values = [:foo, :bar, :baz]
      Minx.spawn do
        @channel.each do |message|
          assert_equal values.shift, message
        end
      end
    end
  end
end
