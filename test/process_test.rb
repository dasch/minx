require 'helper'

class ProcessTest < Test::Unit::TestCase
  should "raise ArgumentError if no block is given" do
    assert_raise(ArgumentError) { Minx::Process.new }
  end

  context "A Minx process" do
    setup do
      @data = ""
      @process = Minx::Process.new {  @data.replace("foo") }
    end

    should "not execute initially" do
      assert_equal "", @data
    end

    should "execute on #spawn" do
      @process.spawn

      assert_equal "foo", @data
    end
  end

  context "A Minx process that yields initially" do
    setup do
      @process = Minx::Process.new { Minx.yield; @value = 42 }
    end

    should "be rescheduled and resumed" do
      @process.spawn

      Minx.join(@process)

      assert_equal 42, @value
    end
  end

  context "Calling Minx.yield from a process" do
    should "return nil when resumed" do
      p = Minx.spawn { assert_nil(Minx.yield) }
    end
  end

  context "Minx.spawn" do
    should "return the spawned process" do
      assert(Minx.spawn { 1 + 1 }.is_a?(Minx::Process))
    end
  end

  context "Spawning a process that is finished" do
    setup do
      @process = Minx.spawn { "Hello, World!" }
    end

    should "raise Minx::ProcessError" do
      assert_raise(Minx::ProcessError) { @process.spawn }
    end
  end

  context "Spawning a process twice" do
    setup do
      @process = Minx.spawn { Minx.yield while true }
    end

    should "raise ProcessError" do
      assert_raise Minx::ProcessError do
        @process.spawn
      end
    end
  end

  context "A blocked child process" do
    should "not block main process" do
      chan1 = Minx.channel
      chan2 = Minx.channel

      Minx.spawn do
        p1 = Minx.spawn do
          val = chan1.read
          flunk "expected to block, but was resumed with value #{val.inspect}"
        end

        p2 = Minx.spawn do
          chan2.write(:foo)
          flunk "expected to block, but was resumed"
        end
      end
    end

    should "be resumed from main process" do
      chan = Minx.channel
      Minx.spawn do
        Minx.spawn do
          Minx.yield
          assert_equal :foo, chan.read
          @bar = :bar
        end
      end
      chan.write(:foo)
      assert_equal :bar, @bar
    end
  end

  context "A blocked child process" do
    should "not block the root process" do
      c = Minx.channel
      Minx.spawn { c.read }
      assert true
    end
  end

  context "Yielding from the root process" do
    should "do nothing" do
      Minx.yield
    end
  end
end
