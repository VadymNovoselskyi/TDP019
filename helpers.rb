require "./types/variable.rb"
require "./types/class.rb"

# Checks if the lhs type is equal to the rhs type (both need to be actual nodes) 
def is_of_equal_types(lhs, rhs)
  if (lhs.eval_type().is_a?(ClassType) && rhs.eval_type().is_a?(ClassType))
    raise "Cannot compare two class types (neither is instance): #{lhs.eval_type().get_class_name()} and #{rhs.eval_type().get_class_name()}"
  end

  if (is_class_type(lhs) && is_class_type(rhs))
    # puts "Comparing two class-related types: #{lhs.eval_type()} and #{rhs.eval_type()}"
    class_type, class_instance = lhs.eval_type().is_a?(ClassType) ? [lhs.eval_type(), rhs] : [rhs.eval_type(), lhs]
    class_name = class_type.get_class_name()
    class_instance = class_instance.is_a?(ClassInstantiation) ? class_instance.evaluate() : class_instance
    # puts "Comparing class instance #{class_instance.get_class_name()} to class name #{class_name}"
    return class_instance.is_subclass_of(class_name)
  end

  # puts "Comparing types: #{lhs.eval_type()} and #{rhs.eval_type()}"
  return lhs.eval_type() == rhs.eval_type()
end 

def is_assignable_to_type(node, type) 
  node = get_value_from_node(node)
  type = type.is_a?(ClassType) ? type.get_class_name() : type
  # puts "Checking if #{node} is assignable to #{type}"
    
  if is_class_type(node)
    # puts "Node is a class type, checking if it is a subclass of #{type} (#{node.is_subclass_of(type)})"
    return node.is_subclass_of(type)
  end

  # puts "Node is not a class type, comparing types: #{node.eval_type()} and #{type}"
  return node.eval_type() == type
end

def is_class_type(node)
  # puts "Checking if node is a class type: #{node.eval_type()}"
  return node.eval_type().is_a?(ClassType) || node.eval_type() == ClassInstanceType || node.eval_type() == ClassInstantiation
end

def get_value_from_node(node)
  node_value = node
  value_name = get_value_name_from_node(node)
  while node_value.instance_variables.include?(value_name)
    node_value = node_value.instance_variable_get(value_name)
    value_name = get_value_name_from_node(node_value)
  end
  return node_value
end

def get_value_name_from_node(node)
  node_value = node
  value_name = nil
  if node_value.instance_variables.include?(:@value)
    value_name = :@value
  elsif node_value.instance_variables.include?(:@new_value)
    value_name = :@new_value
  end
  return value_name
end

def is_lookup_node(node)
  return node.is_a?(VariableLookup) ||
   node.is_a?(ClassAttributeLookup) || 
   node.is_a?(ClassAttributeModification) || 
   node.is_a?(FunctionCall) ||
   node.is_a?(ClassMethodCall)
end