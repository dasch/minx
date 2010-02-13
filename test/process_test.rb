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
      Minx.spawn { @process.spawn }
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
end
