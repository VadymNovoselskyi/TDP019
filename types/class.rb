require "./types/variable.rb"

class ClassVariable < Variable
  attr_accessor :access_attr
  def initialize(type_class, name, access_attr)
    super(type_class, name, nil)
    @access_attr = access_attr
  end

  def clone()
    return ClassVariable.new(@type_class, @name, @access_attr)
  end
end

class ClassType
  attr_accessor :name
 def initialize(name, member_declarations)
   @name = name
   member_variables = []
   member_functions = []
   for declaration in member_declarations
     if declaration.is_a?(ClassVariable)
       member_variables.append(declaration)
     elsif declaration.is_a?(Function)
       member_functions.append(declaration)
     end
   end

   @member_variables = member_variables
   @member_functions = member_functions
 end

  #  TODO: add args
 def new_instance()
   return ClassInstanceType.new(@member_variables.map(&:clone), @member_functions.map(&:clone), @name)
 end

 def evaluate()
   if (name != "Program")
     raise "Cant evaluate cass type definition of class #{name}"
   end
   instance = new_instance()
   return instance.run_function("main", []).evaluate()
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
     @function_scope[function.access_attr.to_sym][function.name] = function
   end
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

   return nil
  #  raise "Class #{@class_name} doesn't have a variable named: #{name}"
   
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

   if (callee == "subclass")
     if (@function_scope[:private][name] != nil)
       return @function_scope[:private][name].evaluate(self, args)
     end
   end

   if (@super != nil)
     return @super.run_function(name, args, "subclass")
   end

   
   raise "Class #{@class_name} doesn't have a function named: #{name}"
 end

 def evaluate()
  return self
 end
end

class ClassAttributeLookup < BaseNode
  attr_accessor :class_name, :name

  def initialize(class_name, name)
    @class_name = class_name
    @name = name
  end

  def eval_type()
    raise "Tried to evaluate the type of a ClassAttributeLookup node"
  end

  def evaluate()
    raise "Tried to evaluate a ClassAttributeLookup node"
  end

  def clone()
    return ClassAttributeLookup.new(@class_name, @name)
  end
end

class ClassAttributeModification < BaseNode
  attr_accessor :class_name, :name, :value

  def initialize(class_name, name, value)
    @class_name = class_name
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
    return ClassAttributeModification.new(@class_name, @name, @value.clone())
  end
end

class ClassMethodCall < BaseNode
  attr_accessor :class_name, :name, :args

  def initialize(class_name, name, args)
    @class_name = class_name
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
    return ClassMethodCall.new(@class_name, @name, @args.map(&:clone))
  end
end