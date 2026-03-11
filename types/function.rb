require "./base.rb"
require "./types/primitives.rb"

class Function < BaseNode
  attr_accessor :access_attr, :return_type, :name, :args, :executables 
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
    
  def evaluate(args = [])
    result = nil
    executables.each { | node |
      result = node.evaluate()
      # puts "result: #{result}"
    }
    return result
  end
end