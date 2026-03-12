require "./base.rb"
require "./types/primitives.rb"

class ArithNode < BaseNode
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end
  
  def eval_type(_scope)
    return Int
  end
  
  def evaluate(scope) 
    if (![Int, Char].include?(@lhs.eval_type(scope)) || ![Int, Char].include?(@rhs.eval_type(scope)))
      raise "Operator #{@op} cannot be applied to operands of type #{@lhs.eval_type(scope)} and #{@rhs.eval_type(scope)}"
    end
    return @lhs.evaluate(scope).send(@op, @rhs.evaluate(scope))
  end
end