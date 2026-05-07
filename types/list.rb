require "./helpers.rb"
require "./types/class.rb"
require "./types/primitives.rb"

class ListInstance
  attr_reader :type, :elements

  def initialize(type, elements = [])
    @type = type

    for element in elements
      if !is_assignable_to_type(element, @type)
        raise "Type error: expected #{@type}, got #{element.eval_type()}"
      end
    end

    @elements = elements
    @contains_classes = type.is_a?(ClassType)
  end

  def set_elements(new_elements)
    @elements = new_elements
  end

  def evaluate()
    return self
  end 

  def eval_type()
    return self.class
  end

  # Used by WriteLine to print the list elements
  def get_elements()
    return @elements
  end

  def run_function(name, args, _callee = nil)
    self.send(name, *args)
  end

  # Actual list methods exposed to csmm
  def At(index)
    index = index.evaluate()
    if index < 0 || index >= @elements.length
      raise "Index out of bounds: #{index}"
    end

    return @elements[index]
  end
  
  def Add(element)
    if !is_assignable_to_type(element, @type)
      raise "Type error: expected #{@type}, got #{element.eval_type()}"
    end
    @elements << element
  end

  def Clear()
    @elements.clear
  end

  def DeleteAt(index)
    index = index.evaluate()
    if index < 0 || index >= @elements.length
      raise "Index out of bounds: #{index}"
    end
    @elements.delete_at(index)
  end

  def Shuffle()
    n = @elements.length
    for i in (n - 1).downto(1) do
      j = rand(0..i)
      @elements[i], @elements[j] = @elements[j], @elements[i]
    end
  end


  def get_attribute(node, _callee = nil)
    if node.is_a?(FunctionCall) || node.is_a?(ClassMethodCall)
      method_name = node.is_a?(FunctionCall) ? node.name : node.method_name
      return run_function(method_name, node.args)
    end
    
    name = node.name
    if name == "Count"
      return Int.new(@elements.length)
    else
      raise "Attribute #{name} not found in ListInstance"
    end
  end

  def method_missing(name, *args)
    raise "No method named '#{name}' found for ListInstance"
  end
end