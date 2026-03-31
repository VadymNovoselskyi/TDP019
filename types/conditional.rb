require "./types/variable.rb"
require "./types/primitives.rb"
require "./base.rb"

class Conditional < BaseNode
  attr_accessor :condition, :if_block, :else_if_blocks, :else_block

  def initialize(condition, if_block, else_if_blocks = [], else_block = nil)
    if (!condition.eval_type() == Bool)
      raise "Condition of an if statement must be of type Boolean, got #{condition.eval_type()}"
    end

    @condition = condition
    @if_block = if_block
    @else_if_blocks = else_if_blocks
    @else_block = else_block
  end

  def evaluate()
    if (@condition.evaluate())
      # puts "If block: #{@if_block.inspect}"
      return @if_block
    end

    # for else_if in @else_if_blocks
    #   if (else_if.condition.evaluate())
    #     return else_if.block.evaluate()
    #   end
    # end

    # if (@else_block != nil)
    #   return @else_block.evaluate()
    # end

    # return nil
  end

  def clone()
    return Conditional.new(
      @condition.clone(), 
      @if_block.map(&:clone), 
      @else_if_blocks.map() { | else_if | else_if.map(&:clone)}, 
      @else_block != nil ? @else_block.map(&:clone) : nil
    )
  end
end