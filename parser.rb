require "./rdparse.rb"
require "./math.rb"

class CSMMParser
        
  def CSMMParser.roll(times, sides)
    # Throw "sides" sided dice "times" times and return the total
    result = (1..times).inject(0) {|sum, _| sum + rand(sides) + 1 }

    # Need to get a new instance since this is a class method
    LoggerFactory.get().info("Rolled #{times}d#{sides} getting #{result}")

    return Atom.new(result)
  end
  
  def initialize

    @logger = LoggerFactory.get()

    @csmmParser = Parser.new("CSMM Parser") do
      token(/\s+/) # Ignore whitespace
      token(/\d+/) {|m| m.to_i } # Any string of digits is converted to an Integer
      token(/./) {|m| m }
      
      start :expr do 
        match(:expr, '+', :term) {|a, _, b| Add.new(a, b) }
        match(:expr, '-', :term) {|a, _, b| Subtract.new(a, b) }
        match(:term)
      end
      
      rule :term do 
        match(:term, '*', :atom) {|a, _, b| Multiply.new(a, b) }
        match(:term, '/', :atom) {|a, _, b| Divide.new(a. b) }
        match(:atom)
      end
      
      rule :atom do
        # Match the result of evaluating an integer expression, which
        # should be an Integer
        match(Integer) { | a | Atom.new(a)}
        match('(', :expr, ')') {|_, a, _| a }
      end
    end
  end
  
  def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
  end
  
  def parse(data)
    print "[CSMMParser] "
    result = @csmmParser.parse data
    puts "=> #{result.evaluate()}"
  end

end

data = File.read("test.csmm")

CSMMParser.new.parse(data)
