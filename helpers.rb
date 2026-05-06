# Checks if the lhs type is equal to the rhs type (both need to be actual nodes) 
def is_equal_types(lhs, rhs)
  if (lhs.eval_type().is_a(ClassType) && rhs.eval_type().is_a(ClassType))
    puts "Comparing class types: #{lhs.eval_type().get_class_name()} and #{rhs.eval_type().get_class_name()}"
    raise "Cannot compare two class types (neither is instance): #{lhs.eval_type().get_class_name()} and #{rhs.eval_type().get_class_name()}"
  end

  if (is_class_type(lhs) && is_class_type(rhs))
    puts "Comparing two class-related types: #{lhs.eval_type()} and #{rhs.eval_type()}"
    class_type = lhs.eval_type().is_a(ClassType) ? lhs.eval_type() : rhs.eval_type()
  end

  if (base_constructor_arg.eval_type().class == ClassType && arg.class == ClassInstantiation)
    # puts "Checking if #{arg.evaluate()} is a subclass of #{base_constructor_arg.get_class_name()}"
    if (!arg.evaluate().is_subclass_of(base_constructor_arg.eval_type().get_class_name())) 
      raise "Trying to assign #{arg.evaluate()} to a variable of type #{base_constructor_arg.eval_type().get_class_name()}" 
    end 
  elsif arg.eval_type() != base_constructor_arg.eval_type() 
    raise "Invalid argument type for class '#{@name}'. Expected #{base_constructor_arg.eval_type()}, received #{arg.eval_type()}" 
  end 
end 
# Asumes everything is a Variable 
# Not classes: just eval_type 
# 
# Classes: 
# .eval_type() returns INSTANCE of ClassType (.is_a(ClassType) returns true): 
# Call .get_class_name() to get the class name (string) 
# 
# .eval_type() return ClassInstantiation: 
# Call .evaluate() to get the class instance, then call .get_class_name() to get the class name (string)
# 
# .eval_type() return ClassInstanceType:
# Call .get_class_name() to get the class name (string)
# 
# If both vars are either ClassType/ClassInstantiation/ClassInstanceType:
# Call is_subclass_of() on one of the variables with name (string) of another

def is_class_type(node)
  return node.eval_type().is_a(ClassType) || node.eval_type().is_a(ClassInstanceType) || node.eval_type().is_a(ClassInstantiation)
end

# Checks if the node is of the given type (the type can be a string or a class) 
def is_assignable_to(node, type) 
  return false 
end