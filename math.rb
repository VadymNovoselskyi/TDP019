require "./base.rb"
require "./types.rb"

class ArithNode < BaseNode
  def initialize(lhs, op, rhs)
      @lhs = lhs
      @op = op
      @rhs = rhs
  end
  
  def eval_type()
    return @lhs.eval_type()
  end

  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end