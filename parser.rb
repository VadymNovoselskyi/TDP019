require "./rdparse.rb"
require "./types.rb"
require "./math.rb"

class CSMMParser
  def initialize

    @logger = LoggerFactory.get()

    @csmmParser = Parser.new("CSMM Parser") do
      token(/\s+/) # Ignore whitespace
      token(/\*\*/) {|m| m }

      token(/\d+/) {|m| m.to_i } # Any string of digits is converted to an Integer
      token(/\w+\b/) {|m| m }
      token(/./) {|m| m }
      
      start :expr do 
        match(:expr, '+', :term) {|a, _, b| ArithNode.new(a, :+, b) }
        match(:expr, '-', :term) {|a, _, b| ArithNode.new(a, :-, b) }
        match(:term)
      end
      
      rule :term do 
        match(:term, '*', :exponent) {|a, _, b| ArithNode.new(a, :*, b) }
        match(:term, '/', :exponent) {|a, _, b| ArithNode.new(a, :/, b) }
        match(:exponent)
      end

      rule :exponent do
        match(:exponent, "**", :atom) {|a, _, b| ArithNode.new(a, :**, b) }
        match(:atom)
      end

      rule :atom do
        # Match the result of evaluating an integer expression, which
        # should be an Integer
        match('(', :expr, ')') {|_, a, _| a }
        match(Integer) { | a | Int.new(a) }
        match("true") {| a | Bool.new(true) }
        match("false") {| a | Bool.new(false) }

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
