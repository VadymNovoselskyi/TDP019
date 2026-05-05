require "./base.rb"

class Variable < BaseNode
  attr_accessor :type_class, :name, :value 
  def initialize(type_class, name, value = nil)
    # puts "Checking type of variable assignment: name: #{name}; value #{value.inspect()}", " type #{type_class.inspect()}"
    if !(value == nil || value.is_a?(FunctionCall) || value.is_a?(ClassMethodCall))
      if (type_class.class == ClassType && value.class == ClassInstantiation)
        if (!value.evaluate().is_subclass_of(type_class.get_class_name()))
          raise "Trying to assign #{value.evaluate()} to a variable of type #{type_class.get_class_name()}"
        end
      elsif (value.eval_type() != type_class)
        raise "Trying to assign #{value.eval_type()} to a variablel of type #{type_class}"
      end
    end
      
      @type_class = type_class
      @name = name
      @value = value
  end
  
  def reassign(new_value)
    # puts "Reassigning variable #{@name} to new value #{new_value.inspect()} of type #{new_value.eval_type()}"
    if (@type_class.class == ClassType && (new_value.eval_type() == ClassInstantiation || new_value.eval_type() == ClassInstanceType))
      if (!new_value.evaluate().is_subclass_of(@type_class.get_class_name()))
        raise "Trying to assign #{new_value.evaluate()} to a variable of type #{@type_class.get_class_name()}"
      end

      @value = new_value.evaluate()
      return
    end
    if (new_value.eval_type() != @type_class)
      raise "Trying to assign #{new_value.eval_type()} to a variablel of type #{@type_class}"
    end
    @value = new_value
  end
  
  def eval_type()
    return @type_class
  end
  
  def evaluate()
    # puts "Evaluating Variable: #{@self.inspect}"

    if (@value == nil) 
      raise "Use of unassigned variable #{@name}"
    end

    return @value.evaluate()
  end

  def clone()
    return Variable.new(@type_class, @name, @value.clone())
  end
   
end

class VariableLookup < BaseNode
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def eval_type()
    raise "Tried to evaluate the type of a VariableLookup node #{@name}"
  end

  def evaluate()
    raise "Tried to evaluate a VariableLookup node #{@name}"
  end

  def clone()
    # raise "Tried to clone a VariableLookup node"
    return VariableLookup.new(@name)
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

  def clone()
    # raise "Tried to clone a Reassign node"
    return Reassign.new(@name, @new_value.clone())
  end
end