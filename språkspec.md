# C#-- (C Sharp minus minus)

## Generell idé:
- En klon av C#
- Statiskt typat
- Interpreterat

### OOP
- Klasser & Objekt
- Ingen async
- Inga Generics
- Inga Funktionella programmeringsfeatures

## Avancerad feature:
- Arv i flera led
- Egen compiler
- Avancerat typsystem

```

class Calculator
{
    int Add(int a, int b)
    {
        return a + b;
    }
}

Calculator calculator = new Calculator();
int result = calculator.Add(2, 3);
WriteLine(result);
```