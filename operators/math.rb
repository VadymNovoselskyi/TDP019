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
    # puts "Evaluating ArithNode: #{@lhs.inspect} #{@op} #{@rhs.inspect}"
    
    if (![Int, Char].include?(@lhs.eval_type()) || ![Int, Char].include?(@rhs.eval_type()))
      raise "Operator #{@op} cannot be applied to operands of type #{@lhs.eval_type()} and #{@rhs.eval_type()}"
    end
    return @lhs.evaluate().send(@op, @rhs.evaluate())
  end

  def clone()
    return ArithNode.new(@lhs.clone(), @op, @rhs.clone())
  end
end