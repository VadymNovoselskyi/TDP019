require "./base.rb"
require "./types/primitives.rb"

class ArithNode < BaseNode
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end
  
  def eval_type()
    return Int
  end
  
  def evaluate() 
    if (![Int, Char].include?(@lhs.eval_type()) || ![Int, Char].include?(@rhs.eval_type()))
      raise "Operator #{@op} cannot be applied to operands of type #{@lhs.eval_type()} and #{@rhs.eval_type()}"
    end
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end