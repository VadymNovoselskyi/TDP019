require "./base.rb"

class Int < BaseNode
  def initialize(number)
    @number = number
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @number
  end

  def clone()
    return Int.new(@number)
  end
   
end

class Bool < BaseNode
  def initialize(val)
    @val = val
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @val
  end

  def clone()
    return Bool.new(@val)
   end

end

class Char < BaseNode
  def initialize(val)
    @val = val.codepoints[1]
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return @val
  end

  def to_s()
    return evaluate().chr()
  end

  def clone()
    return Char.new(to_s())
  end
end

class Void < BaseNode
  def initialize()
  end

  def eval_type()
    return self.class
  end
    
  def evaluate()
    return
  end

  def clone()
    return Void.new()
  end
end
