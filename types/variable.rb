require "./base.rb"

class Variable < BaseNode
  attr_accessor :type_class, :name, :value 
  def initialize(type_class, name, value = nil)
    
    @type_class = type_class
    @name = name
    @value = value
    
  end
  
  def reassign(new_value, scope)
    if (new_value.eval_type(scope) != @type_class)
      raise "Trying to assign #{new_value.eval_type(scope)} to a variablel of type #{@type_class}"
    end
    @value = new_value
  end
  
  def eval_type(_scope)
    return @type_class
  end
  
  def evaluate(scope)
    if (@value == nil) 
      return nil
      # raise "Use of unassigned variable #{@name}"
    end

    if (@type_class != @value.eval_type(scope))
      raise "Trying to assign #{@value.eval_type(scope)} to a variablel of type #{@type_class}"
    end
    return @value.evaluate(scope)
  end
   
end

class VariableLookup < BaseNode
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def eval_type(scope)
    return scope.get(@name).eval_type(scope)
  end

  def evaluate(scope)
    return scope.get(@name).evaluate(scope)
  end
end

class Reassign < BaseNode
  attr_accessor :name
  
  def initialize(name, new_value)
    @name = name
    @new_value = new_value
  end
  def eval_type(scope)
    return @new_value.eval_type(scope)
  end

  def evaluate(scope)
    return @new_value.evaluate(scope)
  end
end