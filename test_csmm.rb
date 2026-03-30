require './parser.rb'
require 'test/unit'

class TestCSMM < Test::Unit::TestCase
  def setup()
    @parser = CSMMParser.new()
  end

  def test_math()
    data = File.read("tests/math.csmm")
    result = @parser.parse(data)
    assert_equal(60, result)
  end

  def test_bool()
    data = File.read("tests/bool.csmm")
    result = @parser.parse(data)
    assert_equal(false, result)
  end
end