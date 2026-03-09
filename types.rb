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

class ClassType
   attr_accessor :name
  def initialize(name, member_variables, member_functions)
    @name = name
    @member_variables = member_variables
    @member_functions = member_functions
  end

  def new_instance()
    return ClassInstanceType.new(@member_variables, @member_functions, @name)
  end

  def evaluate()
    if (name != "Program")
      raise "Cant evaluate cass type definition of class #{name}"
    end
    instance = new_instance()
    return instance.run_function("main", [])
  end
end

class ClassInstanceType 
  def initialize(member_variables, member_functions, class_name)
    @class_name = class_name
    @scope = {}
    if (member_variables == nil) 
      member_variables = []
    end

    if (member_functions == nil) 
      member_functions = []
    end

    for variable in member_variables
      # TODO!! Check copy stuff
      @scope[variable.name] = variable
    end

    for function in member_functions
      # TODO!! Check copy stuff
      @scope[function.name] = function
    end
  end

  def get_attribute(name)
    return @scope[name].evaluate()
  end

  def run_function(name, args)
    if (@scope[name] == nil)
      raise "Class #{@class_name} doesn't have a function named: #{name}"
    end
    return @scope[name].evaluate(args)
  end
end