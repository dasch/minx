require 'helper'
require 'minx/io'

class FileChannelTest < Test::Unit::TestCase
  context "A File channel" do
    setup do
      @chan = Minx::FileChannel.new(FIXTURE_PATH)
    end

    should "read lines from the file" do
      assert_equal "foo\n", @chan.read
      assert_equal "bar\n", @chan.read
      assert_equal "baz\n", @chan.read
    end
  end
end
