require "./base.rb"

class Variable < BaseNode
  attr_accessor :type_class, :name, :value 
  def initialize(type_class, name, value = nil)
    if (value != nil && type_class != value.eval_type())
      raise "Trying to assign #{value.eval_type()} to a variablel of type #{type_class}"
    end

    @type_class = type_class
    @name = name
    @value = value

  end

  def eval_type()
    return @type_class
  end
    
  def evaluate()
    if (@value == nil) 
      return nil
      # raise "Use of unassigned variable #{@name}"
    end
    return @value.evaluate
  end
   
end