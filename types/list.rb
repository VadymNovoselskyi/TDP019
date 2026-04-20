require "./types/class.rb"

class ListType
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def new_instance(elements = [])
    return ListInstance.new(@type, elements)
  end
end

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

  def add(element)
    if !is_correct_type(element)
      raise "Type error: expected #{@type}, got #{element.eval_type()}"
    end
    @elements << element
  end

  def get_element(index)
    return @elements[index]
  end

  def get_elements()
    return @elements
  end

  def evaluate()
    return self
  end 

  def eval_type()
    return self.class
  end

end