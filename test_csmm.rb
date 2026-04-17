require './parser.rb'
require 'test/unit'

class TestCSMM < Test::Unit::TestCase
  def setup()
    @parser = CSMMParser.new()
  end

  def test_math()
    data = File.read("tests/math-function.csmm")
    result = @parser.parse(data)
    assert_equal(29, result)
  end

  def test_bool()
    data = File.read("tests/bool.csmm")
    result = @parser.parse(data)
    assert_equal(true, result)
  end

  def test_fibonacci()
    data = File.read("tests/fib.csmm")
    result = @parser.parse(data)
    assert_equal(55, result)
  end
end