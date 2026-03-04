require "./base.rb"

class ComparisonNode < BaseNode
  def initialize(lhs, op, rhs)
    if lhs.class != rhs.class
      raise "Invalid input to ComparisonNode. Expected #{lhs.class} == #{rhs.class}"
    end
    
      @lhs = lhs
      @op = op
      @rhs = rhs
  end
    
  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end

class LogicNode < BaseNode
  def initialize(lhs, op, rhs)
    if !lhs.is_a(Bool) || !rhs.is_a(Bool) 
      raise "Invalid input to LogicNode. Expected Bool Bool, received: #{lhs.class} #{rhs.class}"
    end
    
      @lhs = lhs
      @op = op
      @rhs = rhs
  end
    
  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end

class NotNode < BaseNode
  def initialize(value)
    if !value.is_a(Bool) 
      raise "Invalid input to NotNode. Expected Bool, received: #{value.class}"
    end
    @value = value
  end

  def evaluate()
    return !@value.evaluate()
  end
end
