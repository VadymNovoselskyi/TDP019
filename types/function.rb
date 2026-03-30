require "./base.rb"
require "./types/primitives.rb"

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
    end
    
    scope = FunctionScope.new(callee, args, @name)

    for node in @executables do
      puts "node: #{node.class}"

      if node.is_a?(Variable) 
        scope.set(node.name, node)
        next
      end
      
      if node.is_a?(Reassign)
        scope.set(node.name, node)
          next
      end
      
      if node.is_a?(ReturnNode)
        # puts "ReturnNode: #{node.inspect}"
        root = replace_viriable_lookup(node, scope)
        if root.eval_type() != @return_type
          raise "Invalid return type for function '#{@name}'. Expected #{@return_type}, returned #{root.eval_type()}"
        end

        # puts "root: #{root.inspect}"
        eval_res = root.evaluate()
        if (eval_res.class <= BaseNode)
          return scope.get(eval_res.name).evaluate()
        end
        return eval_res
      end
    end
  end

  def replace_viriable_lookup(node, scope)
    return node if node == nil
    # puts "--------------------------------"

    if node.is_a?(VariableLookup)
      # puts "Before: node: #{node}"
      # puts "scope.get(node.name): #{scope.get(node.name)}"
      scoped_node = scope.get(node.name)
      # puts "After scope: node: #{node}"
      replaced_node = replace_viriable_lookup(scoped_node, scope)
      # puts "After replace_viriable_lookup: node: #{node}"
      return replaced_node
    end

    if (node.instance_variables.include?(:@lhs))
      # puts "For node: \n#{node} \nLooking up lhs: #{node.instance_variable_get(:@lhs)}"
      old_lhs = node.instance_variable_get(:@lhs)
      replaced_node = replace_viriable_lookup(old_lhs, scope)
      node.instance_variable_set(:@lhs, replaced_node)
    end
    if (node.instance_variables.include?(:@rhs))
      # puts "For node: \n#{node} \nLooking up rhs: #{node.instance_variable_get(:@rhs)}"
      old_rhs = node.instance_variable_get(:@rhs)
      replaced_node = replace_viriable_lookup(old_rhs, scope)
      node.instance_variable_set(:@rhs, replaced_node)
    end
    if (node.instance_variables.include?(:@value))
      # puts "For node: \n#{node} \nLooking up value: #{node.instance_variable_get(:@value)}"
      old_value = node.instance_variable_get(:@value)
      replaced_node = replace_viriable_lookup(old_value, scope)
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