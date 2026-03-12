require "./rdparse.rb"

require "./types/primitives.rb"
require "./types/variable.rb"
require "./types/function.rb"
require "./types/class.rb"

require "./operators/math.rb"
require "./operators/logical.rb"

reserved_words = [
  "return",
  "class",
  "if",
  "else",
  "while",
  "for",
  "true",
  "false",
  "nil",
  "public",
  "private",
  "protected"
]
$id_regex = /^(?!#{reserved_words.join('|')})\w*/

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
          decls.append(decl)
        end
       match(:empty) { [] }
      end

      rule :class_decl do
         match("class", :ID, "{", :member_decls, "}") do |_, class_name, _, decls, _ | 
          ClassType.new(class_name, decls)
        end
      end

      rule :member_decls do
        match(:member_decl, :member_decls) do | decl, decls |
          decls.append(decl)
        end
        match(:empty) { []}
      end

      rule :member_decl do 
        match(:field_decl)
        match(:method_decl)
      end

      rule :field_decl do
        match(:access_modifier, :builtins_type, :ID, ";") do |access, type_class, name, _|  
          ClassVariable.new(type_class, name, access)
        end 
      end
      
      rule :method_decl do 
        match(:access_modifier, :builtins_type, :ID, "(", :opt_param_list, ")", "{", :stmt_list, "}") { 
          | access, type, id , _, params, _,  _, stmt_list, _ |
          Function.new(access, type, id, params, stmt_list.reverse())
        }
      end

      rule :access_modifier do
        match("public")
        match("private")
        match("protected")
        match(:empty) { "public" }
      end

      rule :opt_param_list do
        match(:param, :param_list_tail) { | param, tail |
          tail.append(param)
        }
        match(:empty) { [] }
      end

      rule :param_list_tail do
        match(",", :param, :param_list_tail) { | _, param, tail |
          tail.append(param)
        }
        match(:empty) { [] }
      end

      rule :param do
        match(:builtins_type, :ID) { | type_class, name |
          Variable.new(type_class, name)}
      end

      rule :stmt_list do 
        match(:stmt, :stmt_list) { | stmt, stmt_list | 
          stmt_list.append(stmt)
        }
        match(:empty) { [] }
      end

      rule :stmt do 
        match(:assignment)
        match("return", :expr, ";") { | _, expr, _ | ReturnNode.new(expr) }
        match("return", :ID, ";") { | _, id, _ | ReturnNode.new(id) }
      end

      rule :assignment do
        match(:builtins_type, :ID, ";") { |type_class, name, _| 
          Variable.new(type_class, name)
        }
        match(:builtins_type, :ID, "=", :expr, ";") do |type_class, name, _, value, _|  
          Variable.new(type_class, name, value)
        end
        match(:ID, "=", :expr, ";") do |name, _, value, _| 
          Reassign.new(name, value)
        end
      end

      rule :expr do
        match(:expr, :expr_op, :expr) do | lhs, op, rhs |
          ComparisonNode.new(lhs, op, rhs)
        end

        match(:logical_expr)
        match(:arith_expr)
        match(:literal)
      end

      rule :expr_op do 
        match("==") { :== }
        match("!=") { "!=" }
        match(">") { :> }
        match("<") { :< }
        match(">=") { :>= }
        match("<=") { :<= }
      end

      # Boolean Logic
      rule :logical_expr do
        match(:logical_expr, "&&", :logical_expr) {|a, _, b| LogicNode.new(a, :&, b) }
        match(:logical_expr, "||", :logical_expr) {|a, _, b| LogicNode.new(a, :|, b) }
        match(:logical_expr, "^", :logical_expr) {|a, _, b| LogicNode.new(a, "^", b) }
        
        match("(", :logical_expr, ")") {|_, a, _| a }
        match("!", :logical_expr) {|_, a| NotNode.new(a) }
        
        match("true") {| a | Bool.new(true) }
        match("false") {| a | Bool.new(false) }
        # Combine with literal? Fix later
        match(:ID) { | a | VariableLookup.new(a) }
      end      
      
      # Arithmetic
      rule :arith_expr do 
        match(:arith_expr, '+', :term) {|a, _, b| ArithNode.new(a, :+, b) }
        match(:arith_expr, '-', :term) {|a, _, b| ArithNode.new(a, :-, b) }
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
        match(Integer) { | a | Int.new(a) }
        match("-", Integer) { | _, a | Int.new(-a) }

        # Mabye combine? Fix later
        match(:ID) { | a | VariableLookup.new(a) }
      end

      rule :ID do
        match($id_regex)
      end

      rule :builtins_type do
        match("int") { |_| Int }
        match("bool") { |_| Bool }
        match("char") { |_| Char }
        match("void") { |_| Void }
      end

      rule :literal do
        match(/\'.\'/) { | a | Char.new(a) }
        match(:ID) { | a | VariableLookup.new(a) }
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
