require 'helper'
require 'minx/io'

FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures/data')

class FileChannelTest < Test::Unit::TestCase
  context "A File channel" do
    setup do
      @chan = Minx::File.new(FIXTURE_PATH)
    end

    should "read lines from the file" do
      assert_equal "foo\n", @chan.readline
      assert_equal "bar\n", @chan.readline
      assert_equal "baz\n", @chan.readline
    end
  end

  context "A blocking IO operation" do
    setup do
      @io = Minx::IO.new(File.open('/dev/zero'))
    end

    should "yield to another process" do
      Minx.spawn { @io.readline; assert false }
      assert true
    end
  end
end
