require "./types/variable.rb"

class ClassVariable < Variable
  attr_accessor :access_attr
  def initialize(variable, access_attr)
    super(variable.type_class, variable.name, variable.value)
    @variable = variable
    @access_attr = access_attr
  end

  def clone()
    return ClassVariable.new(@variable, @access_attr)
  end
end

class Constructor
  attr_accessor :constructor, :base_constructor_call_args
  def initialize(constructor, base_constructor_call_args = nil)
    @constructor = constructor
    @base_constructor_call_args = base_constructor_call_args
  end

  def eval_type()
    raise "Tried to evaluate the type of a Constructor node"
  end
  
  def evaluate(instance, args)
    raise "Tried to evaluate a Constructor node" 
  end
end

class ClassType
  attr_accessor :name
  def initialize(name, member_declarations, super_class = nil)
    @name = name
    @super = super_class

    @constructor = nil
    @base_constructor_call_args = nil

    member_variables = []
    member_functions = []
    for declaration in member_declarations
      if declaration.is_a?(ClassVariable)
        member_variables.append(declaration)
      elsif declaration.is_a?(Function)
        member_functions.append(declaration)
      elsif declaration.is_a?(Constructor)
        # puts "constructor: #{declaration.constructor}"
        # puts "base_constructor_call_args: #{declaration.base_constructor_call_args}"
        @constructor = declaration.constructor
        if (@constructor != nil && @constructor.name != @name)
          raise "Constructor name #{@constructor.name} does not match class name #{@name}"
        end 
        @base_constructor_call_args = declaration.base_constructor_call_args
      end
    end

    @member_variables = member_variables
    @member_functions = member_functions
 end

  def new_instance(args = [])
    super_instance = nil
    # puts "Creating new instance of class #{@name}"
    if (@super != nil)
      # puts "Constructor args: #{@constructor.instance_variable_get(:@args)}"
      # puts "Creating super class with args: #{args}; base constructor call args: #{@base_constructor_call_args}"

      resolved_args = {}
      base_constructor_args = @constructor.instance_variable_get(:@args)
      for arg, base_constructor_arg in args.zip(base_constructor_args) do
        if arg.eval_type() != base_constructor_arg.eval_type()
          raise "Invalid argument type for function '#{@name}'. Expected #{base_constructor_arg.eval_type()}, received #{arg.eval_type()}"
        end
        resolved_args[base_constructor_arg.name] = get_primitive_node(arg)
      end
      resolved_args = @base_constructor_call_args.map { |arg| resolved_args[arg.name] }
      super_instance = @super.new_instance(resolved_args)
    end
    return ClassInstanceType.new(@member_variables.map(&:clone), @member_functions.map(&:clone), @name, @constructor, args, super_instance)
  end

 def evaluate()
   if (name != "Program")
     raise "Cant evaluate cass type definition of class #{name}"
   end
   instance = new_instance()
   return instance.run_function("main", []).evaluate()
 end

 def get_class_name()
  return @name
 end
end

class ClassInstantiation 
  attr_accessor :class_type, :args

  def initialize(class_type, args = [])
    @class_type = class_type
    @args = args
  end

  def eval_type()
    return self.class
  end

  def evaluate()
    return @class_type.new_instance(@args)
  end

  def clone()
    return ClassInstantiation.new(@class_type, @args.map(&:clone))
  end
end

class ClassInstanceType 
 def initialize(member_variables, member_functions, class_name, constructor, args, super_class = nil)
   @class_name = class_name
   @constructor = constructor
   @super = super_class

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
     if variable.value && variable.value.eval_type() == ClassInstantiation
       variable.value = variable.value.evaluate()
     end
     @variable_scope[variable.access_attr.to_sym][variable.name] = variable
   end

   for function in member_functions
     @function_scope[function.access_attr.to_sym][function.name] = function
   end

   if (@constructor != nil)
     @constructor.evaluate(self, args)
   end
 end

 def has_attribute(name, callee = "outside")
  if (@variable_scope[:public][name] != nil)
    return true
  end 

  if (callee == "inside" || callee == "subclass")
    if (@variable_scope[:protected][name] != nil)
      return true
    end
  end

  if (callee == "inside")
    if (@variable_scope[:private][name] != nil)
      return true
    end
  end

  if (@super != nil)
    return @super.has_attribute(name, callee == "outside" ? "outside" : "subclass")
  end
  
  return false
 end

# calle can be "outside" "inside" or "subclass"
 def get_attribute(name, callee = "outside")

   if (@variable_scope[:public][name] != nil)
     return @variable_scope[:public][name]
   end

   if (callee == "inside" || callee == "subclass")
    if (@variable_scope[:protected][name] != nil)
      return @variable_scope[:protected][name]
    end
   end
   
   if (callee == "inside")
    if (@variable_scope[:private][name] != nil)
      return @variable_scope[:private][name]
    end
   end

   if (@super != nil)
     return @super.get_attribute(name, callee == "outside" ? "outside" : "subclass")
   end

   raise "Class #{@class_name} doesn't have a variable named: #{name}"
   
 end

 def set_attribute(name, value, callee = "outside")
  if (@variable_scope[:public][name] != nil)
    @variable_scope[:public][name].reassign(value)
    return
  end

  if (callee == "inside" || callee == "subclass")
    if (@variable_scope[:protected][name] != nil)
      @variable_scope[:protected][name].reassign(value)
      return
    end
  end

  if (callee == "inside")
    if (@variable_scope[:private][name] != nil)
      @variable_scope[:private][name].reassign(value)
      return
    end
  end
  
  if (@super != nil)
    @super.set_attribute(name, value, "subclass")
    return
  end

  raise "Class #{@class_name} doesn't have a variable named: #{name}"
 end

 def run_function(name, args, callee = "outside")
   if (@function_scope[:public][name] != nil)
     return @function_scope[:public][name].evaluate(self, args)
   end
   if (callee == "inside" || callee == "subclass")
     if (@function_scope[:protected][name] != nil)
       return @function_scope[:protected][name].evaluate(self, args)
     end
   end

   if (callee == "inside")
     if (@function_scope[:private][name] != nil)
       return @function_scope[:private][name].evaluate(self, args)
     end
   end

   if (@super != nil)
     return @super.run_function(name, args, "subclass")
   end

   raise "Class #{@class_name} doesn't have a function named: #{name}"
 end

 def eval_type()
  return self.class
 end

 def evaluate()
  return self
 end

 def is_subclass_of(class_name)
  if (@class_name == class_name)
    return true
  end

  if (@super != nil)
    return @super.is_subclass_of(class_name)
  end

  return false
 end

 def to_s()
  return "Instance of class #{@class_name}"
 end
end

class ClassAttributeLookup < BaseNode
  attr_accessor :variable_name, :name

  def initialize(variable_name, name)
    @variable_name = variable_name
    @name = name
  end

  def eval_type()
    raise "Tried to evaluate the type of a ClassAttributeLookup node"
  end

  def evaluate()
    raise "Tried to evaluate a ClassAttributeLookup node"
  end

  def clone()
    return ClassAttributeLookup.new(@variable_name, @name)
  end
end

class ClassAttributeModification < BaseNode
  attr_accessor :variable_name, :name, :value

  def initialize(variable_name, name, value)
    @variable_name = variable_name
    @name = name
    @value = value
  end

  def eval_type()
    raise "Tried to evaluate the type of a ClassAttributeModification node"
  end

  def evaluate()
    raise "Tried to evaluate a ClassAttributeModification node"
  end

  def clone()
    return ClassAttributeModification.new(@variable_name, @name, @value.clone())
  end
end

class ClassMethodCall < BaseNode
  attr_accessor :variable_name, :name, :args

  def initialize(variable_name, name, args)
    @variable_name = variable_name
    @name = name
    @args = args
  end  

  def eval_type()
    raise "Tried to evaluate the type of a ClassMethodCall node"
  end

  def evaluate()
    raise "Tried to evaluate a ClassMethodCall node"
  end

  def clone()
    return ClassMethodCall.new(@variable_name, @name, @args.map(&:clone))
  end
end