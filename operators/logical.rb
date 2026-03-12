require "./base.rb"
require "./types/primitives.rb"
require "./types/variable.rb"

class ComparisonNode < BaseNode
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
    
  end
  
  def eval_type(_scope)
    return Bool
  end
  
  def evaluate(scope)
    if @lhs.eval_type(scope) != @rhs.eval_type(scope)
      raise "Invalid input to ComparisonNode. Expected #{@lhs.eval_type(scope)} == #{@rhs.eval_type(scope)}"
    end

    return @lhs.evaluate(scope).send(@op, @rhs.evaluate(scope))
  end
end

class LogicNode < BaseNode
  def initialize(lhs, op, rhs)
    
    @lhs = lhs
    @op = op
    @rhs = rhs
  end
  
  def eval_type(_scope)
    return Bool
  end
  
  def evaluate(scope)
    if (@lhs.eval_type(scope) != Bool || @rhs.eval_type(scope) != Bool)
      raise "Invalid input to LogicNode. Expected Bool Bool, received: #{@lhs.eval_type(scope)} #{@rhs.eval_type(scope)}"
    end
    return @lhs.evaluate(scope).send(@op, @rhs.evaluate(scope))
  end
end

class NotNode < BaseNode
  def initialize(value)
    @value = value
  end
  
  def eval_type(_scope)
    return Bool
  end
  
  def evaluate(scope)
    if (@value.eval_type(scope) != Bool) 
      raise "Invalid input to NotNode. Expected Bool, received: #{@value.eval_type(scope)}"
    end
    return !@value.evaluate(scope)
  end
end
