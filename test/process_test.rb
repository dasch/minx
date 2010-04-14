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

  context "Joining a process" do
    setup do
      @process = Minx::Process.new do
        2.times { Minx.yield }
        @value = 42
      end
    end

    should "wait for that process to finish" do
      @process.spawn
      Minx.join(@process)

      assert_equal 42, @value
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

  context "Nested processes" do
    should "not block main process" do
      chan = Minx.channel
      outer = Minx.spawn do
        inner = Minx.spawn do
          chan.read
          flunk "expected to block, but was resumed"
        end
        Minx.join(inner)
      end
    end

    should "be resumed from main process" do
      chan = Minx.channel
      outer = Minx.spawn do
        inner = Minx.spawn do
          Minx.yield
          assert_equal :foo, chan.read
        end
        Minx.join(inner)
      end
      chan.write(:foo)
    end
  end

  context "A blocked child process" do
    should "not block the root process" do
      c = Minx.channel
      Minx.spawn { c.read }
      assert true
    end
  end
end
