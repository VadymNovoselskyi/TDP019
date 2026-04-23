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

class ClassType
  attr_accessor :name
 def initialize(name, member_declarations)
   @name = name
   @constructor = nil

   member_variables = []
   member_functions = []
   for declaration in member_declarations
     if declaration.is_a?(ClassVariable)
       member_variables.append(declaration)
     elsif declaration.is_a?(Function) && declaration.name == @name
       @constructor = declaration
     elsif declaration.is_a?(Function)
       member_functions.append(declaration)
     end
   end

   @member_variables = member_variables
   @member_functions = member_functions
 end

  #  TODO: add args
 def new_instance()
   puts "Creating new instance of class #{@name}"
   return ClassInstanceType.new(@member_variables.map(&:clone), @member_functions.map(&:clone), @name, @constructor)
 end

 def evaluate()
   if (name != "Program")
     raise "Cant evaluate cass type definition of class #{name}"
   end
   puts "Evaluating Program class"
   instance = new_instance()
   return instance.run_function("main", []).evaluate()
 end

 def get_class_name()
  return @name
 end
end

class ClassInstantiation 
  attr_accessor :class_type

  # TODO: add args
  def initialize(class_type)
    @class_type = class_type
  end

  def eval_type()
    return self.class
  end

  def evaluate()
    return @class_type.new_instance()
  end

  def clone()
    return ClassInstantiation.new(@class_type)
  end
end

class ClassInstanceType 
 def initialize(member_variables, member_functions, class_name, constructor, super_class = nil)
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
    puts "Adding variable #{variable.name} to class #{@class_name} with access modifier #{variable.access_attr}", variable, variable.eval_type()
     if variable.eval_type() == ClassInstantiation
      puts "Evaluating variable #{variable.name} of class #{@class_name}"
       variable.value = variable.value.evaluate()
       puts "Variable #{variable.name} of class #{@class_name} evaluated to #{variable.value}"
     end
     @variable_scope[variable.access_attr.to_sym][variable.name] = variable
   end

   for function in member_functions
     @function_scope[function.access_attr.to_sym][function.name] = function
   end

   if (@constructor != nil)
     @constructor.evaluate(self, [])
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
    return @super.has_attribute(name)
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