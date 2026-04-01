require "./types/variable.rb"
require "./types/primitives.rb"
require "./base.rb"

class Conditional < BaseNode
  attr_accessor :if_branch, :else_if_branches, :else_branch, :conditions

  def initialize(if_branch, else_if_branches = [], else_branch = nil)
    @if_branch = if_branch
    @else_if_branches = else_if_branches
    @else_branch = else_branch

    @conditions = 
      [if_branch.condition] + 
      else_if_branches.map(&:condition) + 
      (else_branch != nil ? [else_branch.condition] : [])
  end

  def evaluate()
    if (@if_branch.should_run())
      # puts "If block: #{@if_block.inspect}"
      return @if_branch.get_block()
    end

    for else_if in @else_if_branches
      if (else_if.should_run())
        # puts "Else if block: #{else_if.inspect}"
        return else_if.get_block()
      end
    end

    if (@else_branch != nil)
      # puts "Else block: #{@else_branch.inspect}"
      return @else_branch.get_block()
    end


    return nil
  end

  def clone()
    return Conditional.new(
      @if_branch.clone(), 
      @else_if_branches.map(&:clone), 
      @else_branch != nil ? @else_branch.clone() : nil
    )
  end
end

class ConditionalBranch
  attr_accessor :condition, :block

  def initialize(condition, block)
    if (!condition.eval_type() == Bool)
      raise "Condition of an if statement must be of type Boolean, got #{condition.eval_type()}"
    end

    @condition = condition
    @block = block
  end

  def should_run()
    return @condition.evaluate()
  end

  def get_block()
    return @block
  end

  def clone()
    return ConditionalBranch.new(@condition.clone(), @block.map(&:clone))
  end
end