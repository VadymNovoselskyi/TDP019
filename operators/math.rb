require "./base.rb"
require "./types/primitives.rb"

class ArithNode < BaseNode
  def initialize(lhs, op, rhs)
      if (![Int, Char].include?(lhs.eval_type()) || ![Int, Char].include?(rhs.eval_type()))
        raise "Operator #{op} cannot be applied to operands of type #{lhs.eval_type()} and #{rhs.eval_type()}"
      end

      @lhs = lhs
      @op = op
      @rhs = rhs
  end
  
  def eval_type()
    return Int
  end

  def evaluate(scope)
    return @lhs.evaluate(scope).send(@op, @rhs.evaluate(scope))
  end
end