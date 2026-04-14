require "./base.rb"
require "./types/primitives.rb"
require "./types/conditional.rb"
require "./types/iterator.rb"

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
    # puts "Evaluating function '#{@name}' with args: #{args.inspect}"
    clone_args = @args.map(&:clone)
    for arg, expected_arg in args.zip(clone_args) do
      if arg.eval_type() != expected_arg.eval_type()
        raise "Invalid argument type for function '#{@name}'. Expected #{expected_arg.eval_type()}, received #{arg.eval_type()}"
      end
      # puts "Reassigning argument: #{get_primitive_node(arg)} to #{expected_arg.inspect}"
      expected_arg.reassign(get_primitive_node(arg))
    end
    
    scope = FunctionScope.new(callee, clone_args, @name)

    clone_executables = @executables.map(&:clone)
    # puts "clone_executables: #{clone_executables.inspect}"
    for node in clone_executables do
      result = handle_executable(node, scope)
      return result if result != nil
    end
  end

  def handle_executable(node, scope)
    # puts "handling executable of type: #{node.class}"
    # puts "node: #{node}", "\n"

    if node.is_a?(Variable) || node.is_a?(Reassign)
      value_name = node.is_a?(Variable) ? :@value : :@new_value
      node_value = node.instance_variable_get(value_name)

      if node_value.is_a?(FunctionCall)
        resolved_value = call_function(scope, node_value.name, node_value.args)
        node.instance_variable_set(value_name, resolved_value)
      elsif node_value
        # puts "node_value: #{node_value}"
        # puts "node_value before replace_lookups: #{node_value}"
        node_value = replace_lookups(node_value, scope)
        # puts "node_value after replace_lookups: #{node_value}"
        resolved_value = get_primitive_node(node_value)
        node.instance_variable_set(value_name, resolved_value)
      end

      scope.set(node.name, node)
      return
    end

    if node.is_a?(FunctionCall)
      call_function(scope, node.name, node.args)
      return
    end
    
    if node.class < Iterable
      puts "Handling iterable node: #{node}"
      puts "Should run? #{node.get_condition()}", "\n"
      if node.is_a?(ForNode)
        # puts "ForNode initial block: #{node.initial_block}"
        handle_executable(node.initial_block, scope)
      end
      
      while true
        # puts "Condition before replace_lookups: #{node.get_condition()}"
        condition = replace_lookups(node.get_condition().clone(), scope)
        # puts "Condition after replace_lookups: #{condition}"
        # puts "Condition evaluated: #{condition.evaluate()}", "\n"
        break unless condition.evaluate()

        iter_executables = node.evaluate()
        # puts "Iter executables: #{iter_executables}"

        for executable in iter_executables do
          # puts "--------------------------------"
          # puts "executable before replace_lookups: #{executable.inspect}"
          # replace_lookups(executable, scope)
          # puts "executable after replace_lookups: #{executable.inspect}"
          result = handle_executable(executable, scope)
          return result if result != nil
        end

        if node.is_a?(ForNode)
          handle_executable(node.increment_block.clone(), scope)
        end
      end
      return
    end

    if node.is_a?(Conditional)
      # puts "replacing lookups for conditions: #{node.conditions.inspect}"
      for condition in node.conditions
        replace_lookups(condition, scope)
      end
      
      executables = node.evaluate()
      # puts "executables: #{executables.inspect}"
      if executables == nil
        return
      end

      for executable in executables
        # puts "executable: #{executable.inspect}"
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

  def replace_lookups(node, scope)
    return node if node == nil
    # puts "--------------------------------"

    if node.is_a?(VariableLookup)
      # puts "Before VariableLookup: #{node}"
      # puts "scope.get(node.name): #{scope.get(node.name)}"
      scoped_node = scope.get(node.name)
      replace_lookups(scoped_node, scope)
      # puts "VariableLookup after replace_lookups: scoped_node: #{scoped_node}"
      return scoped_node
    elsif node.is_a?(FunctionCall)
      # puts "Before: FunctionCall: #{node}"
      function_call_value = call_function(scope, node.name, node.args)
      # puts "FunctionCall after function call: function_call_value: #{function_call_value.class}"
      # puts "After replace_lookups: function_call_value: #{function_call_value}"
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
    if (node.instance_variables.include?(:@new_value))
      # puts "For node: \n#{node} \nLooking up value: #{node.instance_variable_get(:@new_value)}"
      old_value = node.instance_variable_get(:@new_value)
      replaced_node = replace_lookups(old_value, scope)
      node.instance_variable_set(:@new_value, replaced_node)
    end

    return node
  end

  def call_function(scope, name, args)
    new_args = args.map { | arg | replace_lookups(arg, scope).clone() }
    return scope.run_function(name, new_args)
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

    # puts "scope: #{@scope}"
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
    return @callee.run_function(name, args, "inside")
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

  def clone()
    return ReturnNode.new(@value.clone())
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

  def clone()
    return FunctionCall.new(@name, @args.map(&:clone))
  end
end