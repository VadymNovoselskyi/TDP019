require "./rdparse.rb"
require "./types.rb"
require "./math.rb"
require "./logical.rb"

class CSMMParser
  def initialize

    @logger = LoggerFactory.get()

    @variables = {}
    @csmmParser = Parser.new("CSMM Parser") do
      token(/\s+/) # Ignore whitespace
      token(/\*\*/) {|m| m }

      token(/!=/) {|m| m }
      token(/==/) {|m| m }
      token(/>=/) {|m| m }
      token(/<=/) {|m| m }
      token(/>/) {|m| m }
      token(/</) {|m| m }
      token(/&&/) {|m| m }
      token(/\|\|/) {|m| m }
      token(/\^/) {|m| m }

      token(/\d+/) {|m| m.to_i } # Any string of digits is converted to an Integer
      token(/\'.\'/) {|m| m }
      token(/\w+\b/) {|m| m }

      token(/./) {|m| m }

      start :program do
        match(:assignment)
        # match(:comparison)
      end

      rule :assignment do
        match(:builtins_type, :ID, "=", :logical_expr, ";") do |type_class, name, _, value, _|  
          Variable.new(type_class, name, value)
        end
        match(:builtins_type, :ID, "=", :expr, ";") do |type_class, name, _, value, _|  
          Variable.new(type_class, name, value)
        end
      end

      # Boolean Logic
      rule :logical_expr do
        match("(", :logical_expr, ")") {|_, a, _| a }

        match(:logical_expr, "&&", :logical_expr) {|a, _, b| LogicNode.new(a, :&, b) }
        match(:logical_expr, "||", :logical_expr) {|a, _, b| LogicNode.new(a, :|, b) }
        match(:logical_expr, "^", :logical_expr) {|a, _, b| LogicNode.new(a, "^", b) }
        
        match(:comparison)
        match(:literal)
      end

      rule :comparison do
        match(:expr, "==", :expr) {|a, _, b| ComparisonNode.new(a, :==, b) }
        match(:expr, "!=", :expr) {|a, _, b| ComparisonNode.new(a, "!=", b) }
        match(:expr, ">", :expr) {|a, _, b| ComparisonNode.new(a, :>, b) }
        match(:expr, "<", :expr) {|a, _, b| ComparisonNode.new(a, :<, b) }
        match(:expr, ">=", :expr) {|a, _, b| ComparisonNode.new(a, :>=, b) }
        match(:expr, "<=", :expr) {|a, _, b| ComparisonNode.new(a, :<=, b) }
      end
      
      
      # Arithmetic
      rule :expr do 
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
        match(:factor, "**", :exponent) {|a, _, b| ArithNode.new(a, :**, b) }
        match(:factor)
      end

      rule :factor do
        match('(', :expr, ')') {|_, a, _| a }
        match(:literal)
      end

      rule :ID do
        match(/[a-z_]\w*/)
      end

      rule :builtins_type do
        match("int") { |_| Int }
        match("bool") { |_| Bool }
        match("char") { |_| Char }
        match("void") { |_| Void }
      end

      rule :literal do
        match("true") {| a | Bool.new(true) }
        match("false") {| a | Bool.new(false) }
        match(Integer) { | a | Int.new(a) }
        match(/\'.\'/) { | a | Char.new(a) }
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

if __FILE__ == $0
  data = File.read("math.csmm")
  # data = File.read("bool.csmm")
  CSMMParser.new.parse(data)
end
