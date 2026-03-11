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

class ClassVariable < Variable
  attr_accessor :access_attr
  def initialize(type_class, name, access_attr)
    super(type_class, name, nil)
    @access_attr = access_attr
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
  def initialize(member_variables, member_functions, class_name, super_class = nil)
    @super = super_class
    @class_name = class_name

    @variable_scope = {
      :public => {},
      :private => {},
      :protected => {}
    }

    @function_scope = {
      :public => {},
      :private => {},
      :protected => {}
    }

    if (member_variables == nil) 
      member_variables = []
    end

    if (member_functions == nil) 
      member_functions = []
    end

    for variable in member_variables
      # TODO!! Check copy stuff
      @variable_scope[variable.access_attr.to_sym][variable.name] = variable
    end

    for function in member_functions
      # TODO!! Check copy stuff
      @function_scope[function.name] = function
    end
  end

# calle can be "outside" "inside" or "subclass"
  def get_attribute(name, callee = "outside")

    if (@variable_scope[:public][name] != nil)
      return @variable_scope[:public][name]
    end

    if (callee == "inside" || callee == "subclass")
      if (@variable_scope[:private][name] != nil)
        return @variable_scope[:private][name]
      end
    end

    if (callee == "subclass")
      if (@variable_scope[:protected][name] != nil)
        return @variable_scope[:protected][name]
      end
    end

    if (@super != nil)
      return @super.get_attribute(name, "subclass")
    end

    raise "Class #{@class_name} doesn't have a variable named: #{name}"
    
  end

  def run_function(name, args, callee = "outside")
    if (@function_scope[:public][name] != nil)
      return @function_scope[:public][name].evaluate(args)
    end
    if (callee == "inside" || callee == "subclass")
      if (@function_scope[:private][name] != nil)
        return @function_scope[:private][name].evaluate(args)
      end
    end

    if (callee == "subclass")
      if (@function_scope[:protected][name] != nil)
        return @function_scope[:protected][name].evaluate(args)
      end
    end

    if (@super != nil)
      return @super.run_function(name, args, "subclass")
    end

    
    raise "Class #{@class_name} doesn't have a function named: #{name}"
  end
end