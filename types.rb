require "./base.rb"

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