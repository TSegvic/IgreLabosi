using Lab01.Characters;

namespace Lab01.Combat;

public class EnemyAi
{
    private readonly Random random = new();

    public void TakeTurn(Character enemy, Character player)
    {
        Console.WriteLine();
        Console.WriteLine($"{enemy.Name}'s turn...");

        int choice = random.Next(1, 3);

        if (choice == 1 || enemy.Resource < enemy.SpecialAbilityCost)
        {
            Console.WriteLine($"> {enemy.Name} uses a basic attack.");
            enemy.Attack(player);
        }
        else
        {
            Console.WriteLine($"> {enemy.Name} uses {enemy.SpecialAbilityName}.");
            enemy.UseSpecialAbility(player);
        }
    }
}
