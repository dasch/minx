require 'helper'

class ChannelTest < Test::Unit::TestCase
  context "A Channel" do
    setup { @channel = Minx::Channel.new }

    should "be able to transmit a message" do
      data = []

      p1 = Minx::Process.new { @channel.send(:foo) }
      p2 = Minx::Process.new { data << @channel.receive }

      p2.spawn
      p1.spawn

      assert_equal :foo, data.first
    end
  end
end
