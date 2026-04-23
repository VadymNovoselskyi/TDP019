require "./types/class.rb"
require "./types/primitives.rb"

class ListInstance
  attr_reader :type, :elements

  def initialize(type, elements = [])
    @type = type

    for element in elements
      if !is_correct_type(element)
        puts "Element: #{element}"
        puts "Type: #{type.class}"
        raise "Type error: expected #{@type}, got #{element.eval_type()}"
      end
    end

    @elements = elements
    @contains_classes = type.is_a?(ClassType)
  end

  def is_correct_type(element)
    element_type = element.eval_type()
    if @contains_classes
      return element_type == ClassInstanceType && element.is_subclass_of(@type.type.get_class_name())
    end

    return element_type == @type
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
    if !is_correct_type(element)
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


  def get_attribute(name, _callee = nil)
    if name == "Count"
      return Int.new(@elements.length)
    else
      raise "Attribute #{name} not found in ListInstance"
    end
  end

end