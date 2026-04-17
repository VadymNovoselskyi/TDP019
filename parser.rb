require "./rdparse.rb"

require "./types/primitives.rb"
require "./types/variable.rb"
require "./types/function.rb"
require "./types/class.rb"
require "./types/conditional.rb"
require "./types/iterator.rb"

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
  "protected",
  "new"
]
$id_regex = /^(?!#{reserved_words.join('|')})\w+/

class CSMMParser
  def initialize

    @logger = LoggerFactory.get()

    @@class_types = {}
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
          @@class_types[class_name] = ClassType.new(class_name, decls)
          @@class_types[class_name]
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
        match(:access_modifier, :type, :ID, ";") do |access, type_class, name, _|  
          ClassVariable.new(type_class, name, access)
        end 
      end
      
      rule :method_decl do 
        match(:access_modifier, :type, :ID, "(", :opt_param_list, ")", "{", :stmt_list, "}") { 
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
        match(:type, :ID) { | type_class, name |
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
        match(:function_call, ";")
        match(:conditional_stmt)
        match(:loop_stmt)
        match(:return_stmt)
      end

      rule :return_stmt do
        match("return", :logical_expr, ";") { | _, expr, _ | ReturnNode.new(expr) }
        match("return", :ID, ";") { | _, id, _ | ReturnNode.new(id) }
      end

      rule :conditional_stmt do
        match(:if_stmt, :opt_else_ifs, :opt_else) do | if_branch, else_if_branches, else_branch | 
          Conditional.new(if_branch, else_if_branches.reverse(), else_branch)
        end
        
        match(:if_stmt, :opt_else_ifs) do | if_branch, else_if_branches | 
          Conditional.new(if_branch, else_if_branches.reverse())
        end

        match(:if_stmt) do | if_branch | 
          Conditional.new(if_branch)
        end
      end

      rule :if_stmt do
        match("if", "(", :logical_expr, ")", "{", :stmt_list, "}") do | _, _, condition, _, _, then_branch, _ |
          ConditionalBranch.new(condition, then_branch.reverse())
        end
      end

      rule :opt_else_ifs do
        match(:else_if_stmt, :opt_else_ifs) do | else_if_branch, else_if_branches |
          else_if_branches.append(else_if_branch)
        end

        match(:empty) { [] }
      end

      rule :else_if_stmt do
        match("else", "if", "(", :logical_expr, ")", "{", :stmt_list, "}") do | _, _, _, condition, _, _, else_if_branch, _ |
          ConditionalBranch.new(condition, else_if_branch.reverse())
        end
      end

      rule :opt_else do
        match("else", "{", :stmt_list, "}") do | _, _, else_branch, _ | 
          ConditionalBranch.new(Bool.new(true), else_branch.reverse())
        end
        match(:empty) { nil }
      end

      rule :loop_stmt do
        match(:for_stmt)
        match(:while_stmt)
      end

      rule :for_stmt do
        match("for", "(", :assignment_stmt, ";", :logical_expr, ";", :reassignment, ")", "{", :stmt_list, "}") { 
          | _, _, initial_block, _, condition, _, increment_block, _, _, body, _|
          ForNode.new(initial_block, condition, increment_block, body.reverse())
        }
      end

      rule :while_stmt do
        match("while", "(", :logical_expr, ")", "{", :stmt_list, "}") do | _, _, condition, _, _, body, _|
          WhileNode.new(condition, body.reverse())
        end
      end

      rule :assignment do
        match(:declaration, ";")
        match(:assignment_stmt, ";")
        match(:reassignment, ";")
      end
      
      rule :declaration do
        match(:type, :ID) { |type_class, name| 
        Variable.new(type_class, name)
      }
      end
      rule :assignment_stmt do
        match(:type, :ID, "=", :logical_expr) do |type_class, name, _, value|  
          Variable.new(type_class, name, value)
        end
      end
      rule :reassignment do
        match(:ID, "=", :logical_expr) do |name, _, value| 
          Reassign.new(name, value)
        end
      end

      # Boolean Logic
      rule :logical_expr do
        match(:logical_expr, "&&", :comp_expr) {|a, _, b| LogicNode.new(a, :&, b) }
        match(:logical_expr, "||", :comp_expr) {|a, _, b| LogicNode.new(a, :|, b) }
        match(:logical_expr, "^", :comp_expr) {|a, _, b| LogicNode.new(a, "^", b) }
        match("!", :logical_expr) {|_, a| NotNode.new(a) }
        match(:comp_expr)

      end

      rule :comp_expr do
        match(:comp_expr, :expr_op, :logical_expr) do | lhs, op, rhs |
          ComparisonNode.new(lhs, op, rhs)
        end

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
        match('(', :logical_expr, ')') {|_, a, _| a }
        match(:class_instanciation)
        match(:function_call)
        match(:literal)
      end

      rule :class_instanciation do
        match("new", :class_type, "(", :opt_arg_list, ")") do | _, class_type, _, args, _ |
          # TODO: add args
          # puts "Class type: #{class_type}"
          class_type.new_instance()
        end
      end

      rule :function_call do
        match(:ID, "(", :opt_arg_list, ")") do | id, _, args, _ |
          FunctionCall.new(id, args)
        end
      end

      rule :opt_arg_list do
        match(:logical_expr, :arg_list_tail) do | arg, tail |
          tail.append(arg)
          tail
        end
        match(:empty) { [] }
      end

      rule :arg_list_tail do
        match(",", :logical_expr, :arg_list_tail) do | _, arg, tail |
          tail.append(arg)
        end
        match(:empty) { [] }
      end

      rule :ID do
        match($id_regex)
      end

      rule :type do
        match(:builtins_type)
        match(:class_type)
      end

      rule :class_type do
        match(:ID) { | a | @@class_types[a] }
      end

      rule :builtins_type do
        match("int") { |_| Int }
        match("bool") { |_| Bool }
        match("char") { |_| Char }
        match("void") { |_| Void }
      end

      rule :literal do
        match(Integer) { | a | Int.new(a) }
        match("-", Integer) { | _, a | Int.new(-a) }

        match("true") {| a | Bool.new(true) }
        match("false") {| a | Bool.new(false) }
        
        match(/\'.\'/) { | a | Char.new(a) }

        match(:ID) { | a | VariableLookup.new(a) }
      end

    end
  end
  
  def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
  end
  
  def parse(data)
    start = Time.now
    result = @csmmParser.parse data
    endtime = Time.now
    puts "Parsing completed in #{endtime - start} seconds."
    
    puts "Parsing Done. Running program..."
    program_class = result.find { | e | e.name == "Program" }
    start = Time.now
    res = program_class.evaluate()
    endtime = Time.now
    puts "Program executed in #{endtime - start} seconds."
    # puts "Class types: #{@@class_types}"
    return res
  end
  
end

if __FILE__ == $0
  args = ARGV
  filename = args[0] || "tests/fib.csmm"
  data = File.read(filename)
  result = CSMMParser.new.parse(data)
  puts "=> #{result}"
end
