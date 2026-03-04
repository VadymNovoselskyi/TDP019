require "./base.rb"

class Atom < Eval
  def initialize(number)
    @number = number
  end
    
  def evaluate()
    return @number
  end
   
end

class Add < Eval
  def initialize(a, b)
    @a = a
    @b = b
  end
    
  def evaluate()
    return @a.evaluate() + @b.evaluate()
  end
end

class Subtract < Eval
  def initialize(a, b)
    @a = a
    @b = b
  end
    
  def evaluate()
    return @a.evaluate() - @b.evaluate()
  end
end

class Multiply < Eval
  def initialize(a, b)
    @a = a
    @b = b
  end
    
  def evaluate()
    return @a.evaluate() * @b.evaluate()
  end
end

class Divide < Eval
  def initialize(a, b)
    @a = a
    @b = b
  end
    
  def evaluate()
    return @a.evaluate() / @b.evaluate()
  end
end

class Roller < Eval
   def initialize(a, b)
    @a = a
    @b = b
  end
  def evaluate()
    result = (1..@a.evaluate()).inject(0) {|sum, _| sum + rand(@b.evaluate()) + 1 }
    
    return result
  end
end