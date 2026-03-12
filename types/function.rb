require "./base.rb"
require "./types/primitives.rb"

class Function < BaseNode
  attr_accessor :access_attr, :return_type, :name, :args, :executables 

  def initialize(access_attr, return_type, name, args, executables)  
    if !return_type.is_a?(Void) && executables.length == 0
      raise "No executables/return for a function that is not void"
    end
    puts "access_attr: #{access_attr}"
    puts "return_type: #{return_type}"
    puts "name: #{name}"
    puts "args: #{args}"
    puts "executables: #{executables}"

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
    scope = FunctionScope.new(callee, args, @name)

    executables.each { | node |
      puts "node: #{node.class}"
      

      if node.is_a?(Variable) 
        puts "node.name: #{node.name}"
        scope.set(node.name, node)
        next
      end

      if node.is_a?(Reassign)
        scope.set(node.name, node)
        next
      end
      
      if node.is_a?(ReturnNode)
        return node.evaluate(scope) if node.eval_type() <= BaseNode

        return scope.get(node.evaluate(scope).name).evaluate(scope)
      end
      puts "\n\n\n"
    }
  end
end

class FunctionScope 
  def initialize(callee, args, name)
    puts "callee: #{callee}"
    puts "args: #{args}"
    puts "name: #{name}"

    @callee = callee
    @scope = {}
    @name = name
    for arg in args
      @scope[arg.name] = arg
    end
  end
  
  def get(key)
    puts "Getting key: #{key}"
    puts "scope: #{@scope}"

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
    
    end
    
    @scope[key] = value
  end
end

class ReturnNode < BaseNode
  def initialize(value)
    @value = value
  end

  def eval_type()
    return @value.eval_type()
  end

  def evaluate(_scope)
    # return @value.evaluate() if @value.is_a?(BaseNode)
    return @value
  end
end