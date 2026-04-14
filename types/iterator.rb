require "./base.rb"
require "./types/primitives.rb"

class Iterable < BaseNode
  def initialize()
  end

  def get_condition()
    raise "A interable node should not be evaluated directly, it should be used in a loop or conditional statement"
  end
  
  def evaluate()
    raise "A interable node should not be evaluated directly, it should be used in a loop or conditional statement"
  end

  def clone()
    raise "A interable node should not be cloned directly, it should be used in a loop or conditional statement"
   end
end

class WhileNode < Iterable
  attr_accessor :condition, :body

  def initialize(condition, body)
    if (!condition.eval_type() == Bool)
      raise "Condition of a while loop must be of type Boolean, got #{condition.eval_type()}"
    end

    @condition = condition
    @body = body
  end

  def get_condition()
    return @condition
  end

  def evaluate()
    return @body.map(&:clone)
  end

  def clone()
    return WhileNode.new(@condition.clone(), @body.map(&:clone))
  end
end

class ForNode < Iterable
  attr_accessor :initial_block, :condition, :increment_block, :body

  def initialize(initial_block, condition, increment_block, body)
    if (!condition.eval_type() == Bool)
      raise "Condition of a for loop must be of type Boolean, got #{condition.eval_type()}"
    end

    @initial_block = initial_block
    @condition = condition
    @increment_block = increment_block
    @body = body
  end

  def get_condition()
    return @condition
  end

  def evaluate()
    return @body.map(&:clone)
  end

  def clone()
    return ForNode.new(@initial_block.clone(), @condition.clone(), @increment_block.clone(), @body.map(&:clone))
  end
end