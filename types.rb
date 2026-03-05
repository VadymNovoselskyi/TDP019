require "./base.rb"

class Variable < BaseNode
  def initialize(type_class, name, value)
    if type_class != value.eval_type()
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
    return @value.evaluate
  end
   
end

class Int < BaseNode
  def initialize(number)
    @number = number
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @number
  end
   
end

class Bool < BaseNode
  def initialize(val)
    @val = val
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @val
  end
end

class Char < BaseNode
  def initialize(val)
    @val = val.codepoints[1]
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @val
  end

   def to_s()
    return evaluate().chr()
  end
end

class Void < BaseNode
  def initialize()
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return
  end
end