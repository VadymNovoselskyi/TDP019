require "./base.rb"

class ArithNode < Eval
def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end
    
  def evaluate()
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end
end