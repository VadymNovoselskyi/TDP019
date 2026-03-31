require "./base.rb"
require "./types/primitives.rb"
require "./types/conditional.rb"

class Function < BaseNode
  attr_accessor :access_attr, :return_type, :name, :executables 

  def initialize(access_attr, return_type, name, args, executables)  
    if !return_type.is_a?(Void) && executables.length == 0
      raise "No executables/return for a function that is not void"
    end
    # puts "access_attr: #{access_attr}"
    # puts "return_type: #{return_type}"
    # puts "name: #{name}"
    # puts "args: #{args}"
    # puts "executables: #{executables}"

    @access_attr = access_attr
    @return_type = return_type
    @name = name
    @args = args
    @executables = executables

  end
  
  def eval_type()
    return self.class()
  end
  
  def evaluate(callee, args = [])
    for arg, expected_arg in args.zip(@args) do
      if arg.eval_type() != expected_arg.eval_type()
        raise "Invalid argument type for function '#{@name}'. Expected #{expected_arg.eval_type()}, received #{arg.eval_type()}"
      end
      expected_arg.reassign(arg)
    end
    
    scope = FunctionScope.new(callee, @args, @name)

    for node in @executables do
      result = handle_executable(node, scope)
      return result if result != nil
    end
  end

  def handle_executable(node, scope)
    puts "node: #{node.class}"

    if node.is_a?(Variable) || node.is_a?(Reassign)
      scope.set(node.name, resolve_node_value(node, scope))
      return
    end

    if node.is_a?(FunctionCall)
      scope.run_function(node.name, node.args)
      return
    end

    if node.is_a?(Conditional)
      executables = node.evaluate()
      for executable in executables
        result = handle_executable(executable, scope)
        return result if result != nil
      end
      return
    end
    
    if node.is_a?(ReturnNode)
      # puts "ReturnNode: #{node.inspect}"
      root = replace_lookups(node, scope)
      if root.eval_type() != @return_type
        raise "Invalid return type for function '#{@name}'. Expected #{@return_type}, returned #{root.eval_type()}"
      end

      # puts "root: #{root.inspect}"
      return root
    end
  end

  def resolve_node_value(node, scope)
    node_value = node.instance_variable_get(:@value)
    if node_value.is_a?(FunctionCall)
      return_node = scope.run_function(node_value.name, node_value.args)
      node.instance_variable_set(:@value, return_node)
    end
    return node
  end

  def replace_lookups(node, scope)
    return node if node == nil
    # puts "--------------------------------"

    if node.is_a?(VariableLookup)
      # puts "Before: node: #{node}"
      # puts "scope.get(node.name): #{scope.get(node.name)}"
      scoped_node = scope.get(node.name)
      # puts "After scope: node: #{node}"
      replaced_node = replace_lookups(scoped_node, scope)
      # puts "After replace_lookups: node: #{node}"
      return replaced_node
    end
    if node.is_a?(FunctionCall)
      # puts "Before: node: #{node}"
      # puts "scope.get(node.name): #{scope.get(node.name)}"
      function_call_value = scope.run_function(node.name, node.args)
      # puts "After function call: function_call_value: #{function_call_value.class}"
      # replaced_node = replace_lookups(scoped_node, scope)
      # puts "After replace_lookups: node: #{node}"
      return function_call_value
    end

    if (node.instance_variables.include?(:@lhs))
      # puts "For node: \n#{node} \nLooking up lhs: #{node.instance_variable_get(:@lhs)}"
      old_lhs = node.instance_variable_get(:@lhs)
      replaced_node = replace_lookups(old_lhs, scope)
      node.instance_variable_set(:@lhs, replaced_node)
    end
    if (node.instance_variables.include?(:@rhs))
      # puts "For node: \n#{node} \nLooking up rhs: #{node.instance_variable_get(:@rhs)}"
      old_rhs = node.instance_variable_get(:@rhs)
      replaced_node = replace_lookups(old_rhs, scope)
      node.instance_variable_set(:@rhs, replaced_node)
    end
    if (node.instance_variables.include?(:@value))
      # puts "For node: \n#{node} \nLooking up value: #{node.instance_variable_get(:@value)}"
      old_value = node.instance_variable_get(:@value)
      replaced_node = replace_lookups(old_value, scope)
      node.instance_variable_set(:@value, replaced_node)
    end

    return node
  end
end

class FunctionScope 
  def initialize(callee, args, name)
    # puts "callee: #{callee}"
    # puts "args: #{args}"
    # puts "name: #{name}"

    @callee = callee
    @scope = {}
    @name = name
    for arg in args
      @scope[arg.name] = arg
    end
  end
  
  # Gets the class instance. (Doesn't evaluate it)
  def get(key)
    if @scope.has_key?(key)
      return @scope[key]
    elsif @callee.get_attribute(key, "inside")
      return @callee.get_attribute(key, "inside")
    end

    raise "Function '#{@name}' has no variable named '#{key}' in the current context;"
  end

  def set(key, value)
    if @scope.has_key?(key)
      @scope[key].reassign(value)
    elsif @callee.get_attribute(key, "inside")
      @callee.get_attribute(key, "inside").reassign(value)
    else
      @scope[key] = value
    end
  end

  def run_function(name, args)
    @callee.run_function(name, args, "inside")
  end
end

class ReturnNode < BaseNode
  attr_accessor :value
  
  def initialize(value)
    @value = value
  end

  def eval_type()
    return @value.eval_type()
  end

  def evaluate()
    # return @value.evaluate() if @value.is_a?(BaseNode)
    return @value.evaluate()
  end
end

class FunctionCall < BaseNode
  attr_accessor :name, :args

  def initialize(name, args)
    @name = name
    @args = args
  end

  def eval_type()
    raise "Tried to evaluate the type of a FunctionCall node"
  end

  def evaluate()
    raise "Tried to evaluate a FunctionCall node"
  end

end