require './parser.rb'
require 'test/unit'

class TestConstraintNetworks < Test::Unit::TestCase
  def setup()
    @a = Connector.new("a", false)
    @b = Connector.new("b", false)
    @c = Connector.new("c", false)  
    @d = Connector.new("d", false)  
    @e = Connector.new("e", false)  
  end
  def test_adder()
    Adder.new(@a, @b, @c)
    @a.user_assign(10)
    @b.user_assign(5)
    
    assert_equal(15, @c.value)
    
    @a.forget_value "user"
    assert_false(@a.value)
    assert_equal(5, @b.value)
    assert_false(@c.value)

    @c.user_assign(20)
    assert_equal(15, @a.value)
  end
  
  def test_multiplier()
    Multiplier.new(@a, @b, @c)
    @a.user_assign(10)
    @b.user_assign(5)

    assert_equal(50, @c.value)

    @a.forget_value "user"
    assert_false(@a.value)
    assert_equal(5, @b.value)
    assert_false(@c.value)
    
    @c.user_assign(20)
    assert_equal(4, @a.value)
  end

  def test_both()
    Adder.new(@a, @b, @c)
    Multiplier.new(@c, @d, @e)
    @a.user_assign(10)
    @b.user_assign(5)
    @d.user_assign(10)
    assert_equal(150, @e.value)

    @a.forget_value "user"
    assert_false(@a.value)
    assert_equal(5, @b.value)
    assert_false(@c.value)
    assert_equal(10, @d.value)
    assert_false(@e.value)

    @e.user_assign(200)
    assert_equal(20, @c.value)
    assert_equal(15, @a.value)
  end
end