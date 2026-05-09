require "./base.rb"
require "./helpers.rb"
require "./types/primitives.rb"
require "./types/conditional.rb"
require "./types/iterator.rb"
require "./types/writeLine.rb"

class Function < BaseNode
  attr_accessor :access_attr, :return_type, :name, :executables 

  def initialize(access_attr, return_type, name, args, executables)
    if !return_type.is_a?(Void) && executables.length == 0 && return_type != name
      raise "No executables/return for a function that is not void"
    end

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
    clone_args = @args.map(&:clone)

    if args.length != clone_args.length
      raise "Invalid number of arguments for function '#{@name}'. Expected #{@args.length}, received #{args.length}"
    end

    for arg, expected_arg in args.zip(clone_args) do
      if !is_of_equal_types(arg, expected_arg)
        raise "Invalid argument type for function '#{@name}'. Expected #{expected_arg.eval_type()}, received #{arg.eval_type()} for argument '#{expected_arg.name}'"
      end
      expected_arg.reassign(get_primitive_node(arg))
    end
    
    scope = FunctionScope.new(callee, clone_args, @name)

    clone_executables = @executables.map(&:clone)
    for node in clone_executables do
      result = handle_executable(node, scope)
      return result if result != nil
    end
  end

  def handle_executable(node, scope)

    if node.is_a?(BreakNode) 
      return {should_break: true}
    end

    if node.is_a?(ContinueNode)
      return {should_continue: true}
    end

    if node.is_a?(Variable) && node.eval_type() == ClassInstantiation
      class_instance = node.evaluate()
      node.instance_variable_set(:@value, class_instance)
      scope.set(node.name, node)
      return
    end

    if node.is_a?(Variable) || node.is_a?(Reassign) || node.is_a?(ClassAttributeModification)
      value_name = node.is_a?(Variable) || node.is_a?(ClassAttributeModification) ? :@value : :@new_value
      node_value = node.instance_variable_get(value_name)

      # Resolve the value/new_value of the node
      if node_value.is_a?(FunctionCall)
        resolved_value = call_function(scope, node_value.name, node_value.args)
        node.instance_variable_set(value_name, resolved_value)
      elsif node_value && !node.is_a?(ListReassign)
        node_value = replace_lookups(node_value, scope)
        resolved_value = get_primitive_node(node_value)
        node.is_a?(Variable) ? node.reassign(resolved_value) : node.instance_variable_set(value_name, resolved_value)
      end

      if node.is_a?(ClassAttributeModification)
        scope.set_attribute(node.variable_name, node.name, node_value)
      else
        scope.set(node.name, node)
      end
      return
    end

    if node.is_a?(FunctionCall)
      call_function(scope, node.name, node.args)
      return
    end

    if node.is_a?(ClassAttributeLookup)
      replace_lookups(node, scope)
      return
    end
    
    if node.class < Iterable
      if node.is_a?(ForNode)
        handle_executable(node.initial_block, scope)
      end
      
      while true
        condition = replace_lookups(node.get_condition().clone(), scope)
        break unless condition.evaluate()

        iter_executables = node.evaluate()

        iterable_scope = scope.clone()
        for executable in iter_executables do
          result = handle_executable(executable, iterable_scope)
          if (result.is_a?(Hash) && result[:should_break])
            return
          elsif (result.is_a?(Hash) && result[:should_continue])
            break
          end

          return result if result != nil
        end

        if node.is_a?(ForNode)
          handle_executable(node.increment_block.clone(), iterable_scope)
        end

        scope.consolidate_scope(iterable_scope)
      end

      return
    end

    if node.is_a?(Conditional)
      for condition in node.conditions
        replace_lookups(condition, scope)
      end
      
      executables = node.evaluate()
      if executables == nil
        return
      end

      for executable in executables
        result = handle_executable(executable, scope)
        return result if result != nil
      end
      return
    end

    if node.is_a?(WriteLine)
      if node.evaluate().length == 0
        puts "#{get_write_line_prefix()}"
        return
      end

      for arg in node.evaluate()
        arg_value = replace_lookups(arg, scope)
        if arg_value.eval_type() == Char
          value = arg_value.evaluate().chr()
          puts "#{get_write_line_prefix()} #{value}"
        elsif arg_value.eval_type() == ListInstance
          vals = []
          for element in arg_value.evaluate().get_elements()
            element_value = replace_lookups(element, scope)
            vals << element_value.evaluate().to_s()
          end
          puts "#{get_write_line_prefix()} [#{vals.join(", ")}]"
        else
          puts "#{get_write_line_prefix()} #{arg_value.evaluate()}" 
        end
      end
      return
    end
    
    if node.is_a?(ReturnNode)
      root = replace_lookups(node, scope)
      if !is_assignable_to_type(root, @return_type)
        raise "Invalid return type for function '#{@name}'. Expected #{@return_type}, returned #{root.eval_type()}"
      end

      return root
    end
  end

  def get_write_line_prefix()
    return "\e[38;2;0;128;0m[WriteLine]:\e[0m"
  end

  def replace_lookups(node, scope, only_children = false)
    return node if node == nil

    if node.is_a?(VariableLookup) && !only_children
      scoped_node = scope.get(node.name)
      replaced_node = replace_lookups(scoped_node, scope)
      return replaced_node
    elsif node.is_a?(FunctionCall)
      if only_children
        new_args = node.args.map { | arg | replace_lookups(arg, scope).clone() }
        return FunctionCall.new(node.name, new_args)
      end
      function_call_value = call_function(scope, node.name, node.args)
      return function_call_value
    elsif node.is_a?(ClassAttributeLookup)
      replaced_access_chain = replace_lookups(node.access_chain, scope, true)
      replaced_node = node.clone()
      replaced_node.instance_variable_set(:@access_chain, replaced_access_chain)

      return replaced_node if only_children

      class_attribute_value = scope.get_attribute(replaced_node.attribute_name, replaced_node.access_chain)
      return class_attribute_value
    elsif node.is_a?(ClassMethodCall)
      raise "Tried to replace lookups for a ClassMethodCall node. This should be handled by the chain itself, not replace_lookups." if !only_children

      new_args = node.args.map { | arg | replace_lookups(arg, scope).clone() }
      node.instance_variable_set(:@args, new_args)
      return node
    elsif node.is_a?(ClassInstantiation)
      new_args = node.args.map { | arg | replace_lookups(arg, scope).clone() }
      class_instantiation_value = node.class_type.new_instance(new_args)
      return class_instantiation_value
    end

    if (node.instance_variables.include?(:@lhs))
      old_lhs = node.instance_variable_get(:@lhs)
      replaced_node = replace_lookups(old_lhs, scope)
      node.instance_variable_set(:@lhs, replaced_node)
    end
    if (node.instance_variables.include?(:@rhs))
      old_rhs = node.instance_variable_get(:@rhs)
      replaced_node = replace_lookups(old_rhs, scope)
      node.instance_variable_set(:@rhs, replaced_node)
    end
    if (node.instance_variables.include?(:@value))
      old_value = node.instance_variable_get(:@value)
      replaced_node = replace_lookups(old_value, scope)
      node.instance_variable_set(:@value, replaced_node)
    end
    if (node.instance_variables.include?(:@new_value))
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

    @callee = callee
    @scope = {}
    @name = name
    for arg in args
      @scope[arg.name] = arg
    end

  end
  
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
    elsif @callee.has_attribute(key, "inside")
      @callee.get_attribute(key, "inside").reassign(value)
    else
      @scope[key] = value
    end
  end

  def run_function(name, args)
    return @callee.run_function(name, args, "inside")
  end

  def get_attribute(variable_name, attribute)
    if !@scope.has_key?(variable_name) && !@callee.has_attribute(variable_name, "inside")
      raise "Function '#{@name}' has no class instance named '#{variable_name}' in the current context;"
    end

    class_instance = nil
    if @scope.has_key?(variable_name)
      class_instance = @scope[variable_name].value
    elsif @callee.has_attribute(variable_name, "inside")
      class_instance = @callee.get_attribute(variable_name, "inside").value
    end

    return class_instance.get_attribute(attribute, "outside")
  end

  def set_attribute(variable_name, name, value)
    if !@scope.has_key?(variable_name) && !@callee.has_attribute(variable_name, "inside")
      raise "Function '#{@name}' has no class instance named '#{variable_name}' in the current context;"
    end

    class_instance = nil
    if @scope.has_key?(variable_name)
      class_instance = @scope[variable_name].value
    elsif @callee.has_attribute(variable_name, "inside")
      class_instance = @callee.get_attribute(variable_name, "inside").value
    end

    class_instance.set_attribute(name, value)
  end

  def run_class_method(variable_name, name, args)
    if !@scope.has_key?(variable_name) && !@callee.has_attribute(variable_name, "inside")
      raise "Function '#{@name}' has no class instance named '#{variable_name}' in the current context;"
    end

    class_instance = nil
    if @scope.has_key?(variable_name)
      class_instance = @scope[variable_name].value
    elsif @callee.has_attribute(variable_name, "inside")
      class_instance = @callee.get_attribute(variable_name, "inside").value
    end

    return class_instance.run_function(name, args, "outside")
  end

  def clone()
    new_scope = FunctionScope.new(@callee, [], @name)
    for key in @scope.keys
      new_scope.set(key, @scope[key].clone())
    end
    return new_scope
  end

  def consolidate_scope(extended_scope)
    for key in extended_scope.instance_variable_get(:@scope).keys
      next if !@scope.has_key?(key)
      
      @scope[key] = extended_scope.instance_variable_get(:@scope)[key]
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