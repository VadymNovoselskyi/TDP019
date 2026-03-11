require "./rdparse.rb"
require "./types.rb"
require "./math.rb"
require "./logical.rb"

class CSMMParser
  def initialize

    @logger = LoggerFactory.get()

    @variables = {}
    @csmmParser = Parser.new("CSMM Parser") do
      token(/#.*/)
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
        match(:class_decls)
      end

      rule :class_decls do
       match(:class_decl, :class_decls) do | decl, decls |
          if (decls == :empty) 
            decls = []
          end
          decls.append(decl)
          decls
        end
       match(:empty)
      end

      rule :class_decl do
         match("class", :ID, "{", :member_decls, "}") do |_, class_name, _, decls, _ | 
          ClassType.new(class_name, decls, nil)
        end
      end

      rule :member_decls do
        match(:member_decl, :member_decls) do | decl, decls |
          if (decls == :empty) 
            decls = []
          end
          decls.append(decl)
          decls
        end
        match(:empty)
      end

      rule :member_decl do 
        match(:field_decl)
      end

      rule :field_decl do
        match(:access_modifiers, :builtins_type, :ID, ";") do |access, type_class, name, _|  
          ClassVariable.new(type_class, name, access)
        end 
      end

      rule :access_modifiers do
        match("public")
        match("private")
        match("protected")
        match(:empty) { "public" }
      end

      rule :method_decls do
        match(:method_decl, :method_decls) {| method, methods | 
          if (methods == :empty)
            methods= []
          end

          methods.append(method)
          methods
        }
        match(:empty)
      end
      
      rule :method_decl do 
        match(:builtins_type, :ID, "(", :opt_param_list, ")", "{", :stmt_list, "}") { | type, id , _, params, _,  _, stmt_list, _ |
          puts "#{type} #{id} is #{stmt_list[0]}"
          stmt_list[0]
        }
      end

      rule :opt_param_list do
        match(:param, :param_list_tail)
        match(:empty)
      end

      rule :param_list_tail do
        match(",", :param, :param_list_tail)
        match(:empty)
      end

      rule :param do
        match(:builtins_type, :ID)
      end

      rule :stmt_list do 
        match(:stmt, :stmt_list) { | stmt, stmt_list | 
          if (stmt_list == :empty)
            stmt_list = []
          end

          stmt_list.append(stmt)
          stmt_list
        }
        match(:empty)
      end

      rule :stmt do 
        match(:assignment)
      end

      rule :assignment do
        match(:builtins_type, :ID, "=", :expr, ";") do |type_class, name, _, value, _|  
          Variable.new(type_class, name, value)
        end
      end

      rule :expr do
        match(:expr, "==", :expr) {|a, _, b| ComparisonNode.new(a, :==, b) }
        match(:expr, "!=", :expr) {|a, _, b| ComparisonNode.new(a, "!=", b) }
        match(:expr, ">", :expr) {|a, _, b| ComparisonNode.new(a, :>, b) }
        match(:expr, "<", :expr) {|a, _, b| ComparisonNode.new(a, :<, b) }
        match(:expr, ">=", :expr) {|a, _, b| ComparisonNode.new(a, :>=, b) }
        match(:expr, "<=", :expr) {|a, _, b| ComparisonNode.new(a, :<=, b) }

        match(:logical_expr)
        match(:arith_expr)
      end

      # Boolean Logic
      rule :logical_expr do
        match(:logical_expr, "&&", :logical_expr) {|a, _, b| LogicNode.new(a, :&, b) }
        match(:logical_expr, "||", :logical_expr) {|a, _, b| LogicNode.new(a, :|, b) }
        match(:logical_expr, "^", :logical_expr) {|a, _, b| LogicNode.new(a, "^", b) }
        
        match("(", :logical_expr, ")") {|_, a, _| a }
        match(:literal)
      end      
      
      # Arithmetic
      rule :arith_expr do 
        match(:arith_expr, '+', :term) {|a, _, b| ArithNode.new(a, :+, b) }
        match(:ariths_expr, '-', :term) {|a, _, b| ArithNode.new(a, :-, b) }
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
    result = @csmmParser.parse data
    program_class = result.find { | e | e.name == "Program" }
    puts "=> #{program_class.evaluate()}"
  end

end

if __FILE__ == $0
  data = File.read("math.csmm")
  # data = File.read("bool.csmm")
  CSMMParser.new.parse(data)
end
