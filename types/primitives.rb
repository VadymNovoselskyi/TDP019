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
end
