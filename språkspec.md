# C#-- (C Sharp minus minus)

## Generell idé:
- En klon av C#
- Statiskt typat
- Interpreterat
- Komplexa datatyper skickas som referens
- Finns protected/private/public
- Arv & dynamic dispatch
- Nytt scope vid funktion. Inte Loopar
- Klasser har eget scope
- Fungerande aritmetik. (PEMDAS)

### OOP
- Klasser & Objekt
- Ingen async
- Inga Generics
- Inga Funktionella programmeringsfeatures

## Avancerad feature:
- Arv i flera led

# Exempelkod:
```

class Animal
{
    public int ID;

    public Animal(int id)
    {
        ID = id;
    }

    public virtual int MakeSound()
    {
        LogAction(ID);
        return ID;
    }

    protected void LogAction(int value)
    {
        WriteLine(value);
    }

    private int Secret(int x)
    {
        return x * 2;
    }
}

class Dog : Animal
{
    public Dog(int id) : base(id)
    {
    }

    public override int MakeSound()
    {
        int result = ID * 10;
        LogAction(result);
        return result;
    }

    public void RepeatSound(int times)
    {
        if (times <= 0) {
            return;
        }

        for (int i = 0; i < times; i++)
        {
            WriteLine(MakeSound());
        }
    }
}

Animal animal = new Animal(1);
Animal dog = new Dog(2);

WriteLine(animal.MakeSound());
WriteLine(dog.MakeSound());

int counter = 0;

while (counter < 3)
{
    if (counter % 2 == 0) {
        WriteLine(counter);
    }
    else {
        WriteLine(counter * 2);
    }

    counter++;
}

```

# BNF-grammatik:
```
program ::= class_decls ;
class_decls ::= class_decl class_decls | nil
class_decl ::= "class" ID "{" member_decls "}"

member_decls ::= member_decl member_decls | nil
member_decl ::= field_decl | method_decl

field_decl ::= type ID "=" logical_expr ";"| type ID "=" expr ";"
method_decl ::= type ID "(" opt_param_list ")" block

opt_param_list ::= param_list | nil
param_list ::= param param_list_tail ;
param_list_tail::= "," param param_list_tail | nil
param ::= type ID

type ::= builtin_type | ID
builtin_type ::= "void" | "int" | "bool" | "char"

block ::= "{" stmt_list "}"
stmt_list ::= stmt stmt_list | nil
stmt ::= block | if_stmt | while_stmt | for_stmt | return_stmt | expr | ";"

if_stmt ::= "if" "(" expr ")" stmt opt_else
opt_else ::= "else" stmt | nil
while_stmt ::= "while" "(" expr ")" stmt
for_stmt ::= "for" "(" expr ";" expr ";" expr ")" stmt
return_stmt ::= "return" expr ";"

logical_expr ::= logical_expr "&&" logical_expr | logical_expr "||" logical_expr | "(" logical_expr ")" | comparison | literal
comparison ::= expr "==" expr | expr "!=" expr | expr ">" expr | expr "<" expr | expr ">=" expr | expr "<=" expr

expr ::= expr "+" term | expr "-" term | term
term ::= term "*" exponent | term "/" exponent | exponent
exponent ::= factor "**" exponent | factor
factor ::= ID | literal | "(" expr ")"
literal ::= INT | STRING | "true" | "false" | "null"

ID ::= /[a-zA-Z_]\w*/
```