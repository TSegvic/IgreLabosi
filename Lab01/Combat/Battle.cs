using Lab01.Characters;

namespace Lab01.Combat;


public static class Battle
{
    public static void PrintIntro(Character a, Character b)
    {
        Console.WriteLine();
        Console.WriteLine("============================================================");
        Console.WriteLine("                       BATTLE START");
        Console.WriteLine("============================================================");
        a.PrintStatus();
        b.PrintStatus();
        Console.WriteLine("------------------------------------------------------------");
    }

    public static void PrintOutcome(Character a, Character b)
    {
        Console.WriteLine();
        Console.WriteLine("============================================================");
        Console.WriteLine("                       BATTLE END");
        Console.WriteLine("============================================================");

        if (a.IsAlive && !b.IsAlive)
            Console.WriteLine($"Winner: {a.Name} ({a.ClassName})");
        else if (b.IsAlive && !a.IsAlive)
            Console.WriteLine($"Winner: {b.Name} ({b.ClassName})");
        else if (!a.IsAlive && !b.IsAlive)
            Console.WriteLine("Draw - both combatants fell.");
        else
            Console.WriteLine("Battle ended without a clear winner.");

        Console.WriteLine();
        a.PrintStatus();
        b.PrintStatus();
        Console.WriteLine("============================================================");
    }

    public static void PrintRoundHeader(int round, string actor, string action)
    {
        Console.WriteLine();
        Console.WriteLine($"-- Round {round} | {actor}: {action} --");
    }
}
