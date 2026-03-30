require "./base.rb"

class Variable < BaseNode
  attr_accessor :type_class, :name, :value 
  def initialize(type_class, name, value = nil)
    
    @type_class = type_class
    @name = name
    @value = value
    
  end
  
  def reassign(new_value)
    if (new_value.eval_type() != @type_class)
      raise "Trying to assign #{new_value.eval_type()} to a variablel of type #{@type_class}"
    end
    @value = new_value
  end
  
  def eval_type()
    return @type_class
  end
  
  def evaluate()
    if (@value == nil) 
      return nil
      # raise "Use of unassigned variable #{@name}"
    end

    # if (@type_class != @value.eval_type())
    #   raise "Trying to assign #{@value.eval_type()} to a variablel of type #{@type_class}"
    # end
    return @value.evaluate()
  end
   
end

class VariableLookup < BaseNode
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def eval_type()
    puts "VariableLookup eval_type: #{@name}"
    # return scope.get(@name).eval_type(scope)
    return @name
  end

  def evaluate()
    puts "VariableLookup evaluate: #{@name}"
    # return scope.get(@name).evaluate(scope)
    return @name
  end
end

class Reassign < BaseNode
  attr_accessor :name
  
  def initialize(name, new_value)
    @name = name
    @new_value = new_value
  end
  def eval_type()
    return @new_value.eval_type()
  end

  def evaluate()
    return @new_value.evaluate()
  end
end