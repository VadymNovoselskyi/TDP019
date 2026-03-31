require "./base.rb"
require "./types/primitives.rb"
require "./types/variable.rb"

class ComparisonNode < BaseNode
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
    
  end
  
  def eval_type()
    return Bool
  end
  
  def evaluate()
    if @lhs.eval_type() != @rhs.eval_type()
      raise "Invalid input to ComparisonNode. Expected #{@lhs.eval_type()} == #{@rhs.eval_type()}"
    end

    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end

  def clone()
    return ComparisonNode.new(@lhs.clone(), @op, @rhs.clone())
  end
end

class LogicNode < BaseNode
  def initialize(lhs, op, rhs)
    
    @lhs = lhs
    @op = op
    @rhs = rhs
  end
  
  def eval_type()
    return Bool
  end
  
  def evaluate()
    if (@lhs.eval_type() != Bool || @rhs.eval_type() != Bool)
      raise "Invalid input to LogicNode. Expected Bool Bool, received: #{@lhs.eval_type()} #{@rhs.eval_type()}"
    end
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end

  def clone()
    return LogicNode.new(@lhs.clone(), @op, @rhs.clone())
  end
end

class NotNode < BaseNode
  def initialize(value)
    @value = value
  end
  
  def eval_type()
    return Bool
  end
  
  def evaluate()
    if (@value.eval_type() != Bool) 
      raise "Invalid input to NotNode. Expected Bool, received: #{@value.eval_type()}"
    end
    return !@value.evaluate()
  end

  def clone()
    return NotNode.new(@value.clone())
  end
end
