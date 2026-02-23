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