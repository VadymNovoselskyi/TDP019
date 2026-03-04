require "./base.rb"

class Variable < BaseNode
  def initialize(name, value)
    @name = name
    @value = value
  end
    
  def evaluate()
    return @value.evaluate
  end
   
end

class Int < BaseNode
  def initialize(number)
    @number = number
  end
    
  def evaluate()
    return @number
  end
   
end

class Bool < BaseNode
  def initialize(val)
    @val = val
  end
    
  def evaluate()
    return @val
  end
end

class Char < BaseNode
  def initialize(val)
    @val = val
  end
    
  def evaluate()
    return @val
  end
end

class Void < BaseNode
  def initialize()
  end
    
  def evaluate()
    return
  end
end