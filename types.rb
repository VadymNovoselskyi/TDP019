require "./base.rb"

class Int < Eval
  def initialize(number)
    @number = number
  end
    
  def evaluate()
    return @number
  end
   
end

class Bool < Eval
  def initialize(val)
    @val = val
  end
    
  def evaluate()
    return @val
  end
end