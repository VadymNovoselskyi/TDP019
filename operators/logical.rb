require "./base.rb"
require "./types/primitives.rb"

class ComparisonNode < BaseNode
  def initialize(lhs, op, rhs)
    if (lhs.eval_type() != rhs.eval_type()) && lhs.is_a?(VariableLookup) && rhs.is_a?(VariableLookup)
      raise "Invalid input to ComparisonNode. Expected #{lhs.eval_type()} == #{rhs.eval_type()}"
    end
    
    @lhs = lhs
    @op = op
    @rhs = rhs

  end

  def eval_type()
    return Bool
  end

  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end

class LogicNode < BaseNode
  def initialize(lhs, op, rhs)
    if (lhs.eval_type() != Bool || rhs.eval_type() != Bool)
      raise "Invalid input to LogicNode. Expected Bool Bool, received: #{lhs.eval_type()} #{rhs.eval_type()}"
    end
    
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def eval_type()
    return Bool
  end
    
  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end

class NotNode < BaseNode
  def initialize(value)
    if (value.eval_type() != Bool) 
      raise "Invalid input to NotNode. Expected Bool, received: #{value.eval_type()}"
    end
    @value = value
  end

  def eval_type()
    return Bool
  end

  def evaluate()
    return !@value.evaluate()
  end
end
