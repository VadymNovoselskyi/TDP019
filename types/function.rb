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
        eval_res = node.evaluate(scope)
        if (eval_res.class <= BaseNode)
          return scope.get(eval_res.name).evaluate(scope)
        end
        return eval_res
      end
    end
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
      @scope[key].reassign(value, self)
    elsif @callee.get_attribute(key, "inside")
      @callee.get_attribute(key, "inside").reassign(value, self)
    else
      @scope[key] = value
    end
  end
end

class ReturnNode < BaseNode
  def initialize(value)
    @value = value
  end

  def eval_type(scope)
    return @value.eval_type(scope)
  end

  def evaluate(_scope)
    return @value.evaluate(_scope)
  end
end