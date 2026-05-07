require "./types/variable.rb"
require "./types/class.rb"

# Checks if the lhs type is equal to the rhs type (both need to be actual nodes) 
def is_equal_types(lhs, rhs)
  if (lhs.eval_type().is_a?(ClassType) && rhs.eval_type().is_a?(ClassType))
    puts "Comparing class types: #{lhs.eval_type().get_class_name()} and #{rhs.eval_type().get_class_name()}"
    raise "Cannot compare two class types (neither is instance): #{lhs.eval_type().get_class_name()} and #{rhs.eval_type().get_class_name()}"
  end

  if (is_class_type(lhs) && is_class_type(rhs))
    puts "Comparing two class-related types: #{lhs.eval_type()} and #{rhs.eval_type()}"
    class_type, class_instance = lhs.eval_type().is_a?(ClassType) ? [lhs.eval_type(), rhs] : [rhs.eval_type(), lhs]
    class_name = class_type.get_class_name()
    class_instance = class_instance.is_a?(ClassInstantiation) ? class_instance.evaluate() : class_instance
    puts "Comparing class instance #{class_instance.get_class_name()} to class name #{class_name}"
    return class_instance.is_subclass_of(class_name)
  end

  puts "Comparing types: #{lhs.eval_type()} and #{rhs.eval_type()}"
  return lhs.eval_type() == rhs.eval_type()
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
  # puts "Checking if node is a class type: #{node.eval_type()}"
  return node.eval_type().is_a?(ClassType) || node.eval_type() == ClassInstanceType || node.eval_type() == ClassInstantiation
end

def is_assignable_to(node, type) 
  type = type.is_a?(ClassType) ? type.get_class_name() : type
  # puts "Checking if #{node.eval_type()} is assignable to #{type}"
    
  if is_class_type(node)
    # puts "Node is a class type, checking if it is a subclass of #{type} (#{node.is_subclass_of(type)})"
    return node.is_subclass_of(type)
  end

  # puts "Node is not a class type, comparing types: #{node.eval_type()} and #{type}"
  return node.eval_type() == type
end