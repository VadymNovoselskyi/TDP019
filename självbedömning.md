Projektet bedöms nå betyg: 5

## Köra projektet:
Projektet körs genom att köra filen parser.rb med ruby samt ge ett filnamn som en parameter. 
Ex:
 
```shell
ruby parser.rb tests/fib.csmm
```

## Motivation för betyg 3:
Språket har stöd för:

- `for`- och `while`-loopar
- `if`-, `else`- och `else if`-satser

Det gör det enkelt att kontrollera programmets flöde.

Det finns även stöd för variabler, funktioner, aritmetik och boolean aritmetik. 

Kodexempel:
```cs
# Funktioner och Aritmetik
class Program {
   private int tmp;

    public int main() {
        tmp = 50;
        int tmp2 = 20;
        int tmp3 = 2;
        int tmp5 = -5;
        tmp5 = tmp5 - 1;
        int tmp4 = 10 + tmp5;
        add(10, 20);

        # Returns 29
        return add(tmp4, add(5, 10)) + get_10();
    }

    private int add(int a, int b) {
        return a + b;
    }

    private int get_10() {
        return 10;
    }
}
```

```cs
# Styrstrukturer (if-satser, for- och while-loopar)
class Program {
    public int main() {
        int a = 0;
        for (int i = 0; i < 10; i = i + 1) {
            a = a + i;
            if(a > 20) {
                break;
            }
            # [WriteLine]: 0, 1, 3, 6, 10, 15 (one value each iteration)
            WriteLine(a);
        }

        int b = 0;
        while (b <= 10) {
            b = b + 1;
            continue;

            # Never prints
            WriteLine('x');
        }
        
        # [WriteLine]: 11
        WriteLine(b);

        # Returns: 21
        return a;
    }
}
```

## Motivation för betyg 4:
Språket har även stöd för:

- Rekursion
- Listor
- Funktioner för listor, såsom `Add`, `DeleteAt` och `Clear`

Kodexempel:
```cs
# Rekursion
class Program {
    public int main() {
        int n = 10;
        
        # Returns: 55
        return Fibonacci(n);
    }

    public int Fibonacci(int n) {
        if ((n == 0) || n < 0) {
            return 0;
        }

        if (n == 1) {
            return 1;
        }

        return Fibonacci(n - 1) + Fibonacci(n - 2);
    }
}
```

Kodexempel:
```cs
# Listor
class Program {

    public int test(int a) {
        return a;
    }

    public int main() {
        List<int> list = [1, 2, 3, 4];
        
        # [WriteLine]: [1, 2, 3, 4]
        WriteLine(list);
        
        list.Add(69);
        
        # [WriteLine]: [1, 2, 3, 4, 69]
        WriteLine(list);

        # [WriteLine]: 5
        WriteLine(list.Count);

        # [WriteLine]: 69
        WriteLine(list.At(list.Count - 1));

        list = [10, 20, 30, 40];

        # [WriteLine]: [10, 20, 30, 40]
        WriteLine(list);

        list.DeleteAt(1);
        list.DeleteAt(2);

        # [WriteLine]: [10, 30]
        WriteLine(list);

        int a = list.At(1);
        # [WriteLine]: 30
        WriteLine(a);

        List<bool> boolShit = [true, true, false];
        
        # [WriteLine]: [true, true, false]
        WriteLine(boolShit);

        boolShit.Add(1 == 2);
        
        # [WriteLine]: [true, true, false, false]
        WriteLine(boolShit);

        boolShit = [false, false, true && false || true];
        
        # [WriteLine]: [false, false, true]
        WriteLine(boolShit);

        # Would throw
        #boolShit = [1, 2, 3];
        #WriteLine(boolShit);
    
        return 1;
    }
}
```

## Motivation för betyg 5:
Språket är helt klassbaserat med arv, polymorfi och dynamic dispatch.

Kodexempel:
```cs 
class Test {
    public int pub_var;
    protected int prot_var;
    private int priv_var;

    public Test(int c) {
        pub_var = c;
    }

    private void hidden_func() {
        pub_var = 14;
    }

    protected int double() {
        return prot_var  * 2;
    }
}

class TestTest : Test {
    public TestTest(int a, int b): base(a) {
        prot_var = b;
    }

    public int triple() {
        return double() + prot_var;
    }
}

class TestTestTest : TestTest {
    public TestTestTest(int a, int b, int c) : base(a, b) {
    }

    public int triple() {
        return 20;
    }
}



class Program {    
    public int main() {
        TestTestTest testTestTest = new TestTestTest(20, 30, 40);

        # [WriteLine]: 20
        WriteLine(testTestTest.triple());

        TestTest testTest = new TestTest(20, 30);
        
        # [WriteLine]: 90
        WriteLine(testTest.triple());

        return 1;
    }
}

```