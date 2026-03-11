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

    @scope = {}
  end
  
  def eval_type()
    return self.class()
  end
    
  def evaluate(args = [])
    executables.each { | node |
      puts "node: #{node.class}"
      

      if node.is_a?(Variable) 
        puts "node.name: #{node.name}"
        @scope[node.name] = node
        puts @scope
        next
      end

      if node.is_a?(Reassign)
        if !@scope.has_key?(node.name)
          raise "Function '#{@name}' has no variable named '#{node.name}' in the current context;"
        end
        @scope[node.name].reassign(node)
        next
      end
      
      if node.is_a?(ReturnNode)
        return node.evaluate() if node.eval_type() <= BaseNode

        result = node.evaluate() 
        if !@scope.has_key?(result)
          raise "Function '#{@name}' has no variable named '#{result}' in the current context;"
        end

        return @scope[result].evaluate()
      end
      puts "\n\n\n"
    }
  end
end

class ReturnNode < BaseNode
  def initialize(value)
    @value = value
  end

  def eval_type()
    return @value.eval_type()
  end

  def evaluate()
    return @value.evaluate() if @value.is_a?(BaseNode)
    return @value
  end
end