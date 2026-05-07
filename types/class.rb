require "./types/variable.rb"
require "./helpers.rb"

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
    if (@super != nil)

      resolved_args = {}
      base_constructor_args = @constructor.instance_variable_get(:@args)
      if (args.length != base_constructor_args.length)
        raise "Invalid number of arguments for constructor of class '#{@name}'. Expected #{base_constructor_args.length}, received #{args.length}"
      end

      for arg, base_constructor_arg in args.zip(base_constructor_args) do
        if !is_of_equal_types(arg, base_constructor_arg)
          raise "Invalid argument type for constructor of class '#{@name}'. Expected #{base_constructor_arg.eval_type()}, received #{arg.eval_type()}"
        end  
        resolved_args[base_constructor_arg.name] = get_primitive_node(arg)
      end

      resolved_args = @base_constructor_call_args.map { |arg|
        if arg.is_a?(VariableLookup)
          resolved_args[arg.name]
        else
          arg
        end 
      }
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

 def is_subclass_of(class_name)
  if (@name == class_name)
    return true
  end

  if (@super != nil)
    return @super.is_subclass_of(class_name)
  end

  return false
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

  def is_subclass_of(class_name)
    return @class_type.is_subclass_of(class_name)
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

 def handle_chain_access(node, callee = "outside")
  if node.is_a?(VariableLookup)
    return get_attribute(node.name, callee)
  elsif node.is_a?(FunctionCall)
    return run_function(node.name, node.args, callee)
  elsif node.is_a?(ClassAttributeLookup)
    class_attribute_value = get_attribute(node.attribute_name, callee).value
    return class_attribute_value.handle_chain_access(node.access_chain, callee == "outside" ? "outside" : "subclass")
  elsif node.is_a?(ClassMethodCall)
    class_method_value = run_function(node.method_name, node.args, callee).evaluate()
    return class_method_value.handle_chain_access(node.access_chain, callee == "outside" ? "outside" : "subclass")
  else
    raise "Unsupported node type in attribute access chain: #{node.class}"
  end
 end

# calle can be "outside" "inside" or "subclass"
  def get_attribute(attribute, callee = "outside")
    if (attribute.class != String)
      return handle_chain_access(attribute, callee)
    end

    if (@variable_scope[:public][attribute] != nil)
      return @variable_scope[:public][attribute]
    end

    if (callee == "inside" || callee == "subclass")
      if (@variable_scope[:protected][attribute] != nil)
        return @variable_scope[:protected][attribute]
      end
    end

    if (callee == "inside")
      if (@variable_scope[:private][attribute] != nil)
        return @variable_scope[:private][attribute]
      end
    end

    if (@super != nil)
      return @super.get_attribute(attribute, callee == "outside" ? "outside" : "subclass")
    end

    raise "Class #{@class_name} doesn't have a variable named: #{attribute}"
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

 def get_class_name()
  return @class_name
 end

 def to_s()
  return "Instance of class #{@class_name}"
 end
end

class ClassAttributeLookup < BaseNode
  attr_accessor :attribute_name, :access_chain

  def initialize(attribute_name, access_chain)
    @attribute_name = attribute_name
    @access_chain = access_chain
  end

  def eval_type()
    raise "Tried to evaluate the type of a ClassAttributeLookup node with attribute access_chain #{@access_chain}"
  end

  def evaluate()
    raise "Tried to evaluate a ClassAttributeLookup node"
  end

  def clone()
    return ClassAttributeLookup.new(@attribute_name, @access_chain.clone())
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
    raise "Tried to evaluate the type of a ClassAttributeModification node with attribute name #{@name}"
  end

  def evaluate()
    raise "Tried to evaluate a ClassAttributeModification node"
  end

  def clone()
    return ClassAttributeModification.new(@variable_name, @name, @value.clone())
  end
end

class ClassMethodCall < BaseNode
  attr_accessor :method_name, :args, :access_chain

  def initialize(method_name, args, access_chain)
    @method_name = method_name
    @args = args
    @access_chain = access_chain
  end  

  def eval_type()
    raise "Tried to evaluate the type of a ClassMethodCall node with method name #{@method_name}"
  end

  def evaluate()
    raise "Tried to evaluate a ClassMethodCall node"
  end

  def clone()
    return ClassMethodCall.new(@method_name, @args.map(&:clone), @access_chain.clone())
  end
end