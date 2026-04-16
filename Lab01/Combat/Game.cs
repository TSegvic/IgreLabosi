using Lab01.Characters;
using Lab01.Effects;
using Lab01.Items;

namespace Lab01.Combat;

public class Game
{
    private Character player = null!;
    private Character enemy = null!;

    private HealingPotion healingPotion = null!;
    private BuffPotion buffPotion = null!;

    private readonly EnemyAi enemyAi = new();

    public void Run()
    {
        SetupGame();
        BattleLoop();
        PrintWinner();
    }

    private void SetupGame()
    {
        PrintHeader("Interactive RPG Battle");

        player = CreatePlayer();
        enemy = CreateEnemy();

        SetupItems();

        Console.WriteLine();
        Console.WriteLine("Battle begins.");
    }

    private Character CreatePlayer()
    {
        Console.WriteLine("Choose your class:");
        Console.WriteLine("1. Warrior");
        Console.WriteLine("2. Mage");
        Console.WriteLine("3. Rogue");
        Console.Write("Choice: ");

        string? choice = Console.ReadLine();

        Console.Write("Enter character name: ");
        string name = Console.ReadLine() ?? "Player";

        return choice switch
        {
            "1" => new Warrior(name),
            "2" => new Mage(name),
            "3" => new Rogue(name),
            _ => new Warrior(name)
        };
    }

    private Character CreateEnemy()
    {
        Character createdEnemy = new Mage("Dark Sorcerer");

        var weapon = new Weapon("Dark Staff", 10, 4);

        createdEnemy.Inventory.AddItem(weapon);
        createdEnemy.EquipWeapon(weapon);

        return createdEnemy;
    }

    private void SetupItems()
    {
        var sword = new Weapon("Steel Sword", 8, 4);
        var armor = new Armor("Knight Armor", 5, 8);

        healingPotion = new HealingPotion("Healing Potion", 30);

        buffPotion = new BuffPotion(
            name: "Power Potion",
            description: "+5 attack for 3 turns",
            weight: 1,
            effectFactory: () => new StatBuffEffect(
                "Power Boost",
                attackBonus: 5,
                defenseBonus: 0,
                turns: 3));

        player.Inventory.AddItem(sword);
        player.Inventory.AddItem(armor);
        player.Inventory.AddItem(healingPotion);
        player.Inventory.AddItem(buffPotion);

        player.EquipWeapon(sword);
        player.EquipArmor(armor);
    }

    private void BattleLoop()
    {
        int round = 1;

        while (player.IsAlive && enemy.IsAlive)
        {
            Console.WriteLine();
            Console.WriteLine($"========== ROUND {round} ==========");

            PlayerTurn();

            if (!enemy.IsAlive)
                break;

            EnemyTurn();

            round++;
        }
    }

    private void PlayerTurn()
    {
        player.OnTurnStart();

        Console.WriteLine();
        Console.WriteLine("PLAYER STATUS:");
        player.PrintStatus();

        Console.WriteLine();
        Console.WriteLine("ENEMY STATUS:");
        enemy.PrintStatus();

        Console.WriteLine();
        Console.WriteLine("Choose action:");
        Console.WriteLine("1. Basic Attack");
        Console.WriteLine($"2. {player.SpecialAbilityName} ({player.SpecialAbilityCost} {player.ResourceName})");
        Console.WriteLine("3. Healing Potion");
        Console.WriteLine("4. Buff Potion");
        Console.Write("Action: ");

        string? action = Console.ReadLine();

        Console.WriteLine();

        switch (action)
        {
            case "1":
                player.Attack(enemy);
                break;

            case "2":
                player.UseSpecialAbility(enemy);
                break;

            case "3":
                player.Inventory.UseItem(healingPotion, player);
                break;

            case "4":
                player.Inventory.UseItem(buffPotion, player);
                break;

            default:
                Console.WriteLine("Invalid action.");
                break;
        }
    }

    private void EnemyTurn()
    {
        enemy.OnTurnStart();
        enemyAi.TakeTurn(enemy, player);
    }

    private void PrintWinner()
    {
        Console.WriteLine();
        Console.WriteLine("============================");

        if (player.IsAlive)
            Console.WriteLine($"{player.Name} wins the battle.");
        else
            Console.WriteLine($"{enemy.Name} wins the battle.");

        Console.WriteLine("============================");
    }

    private static void PrintHeader(string title)
    {
        Console.WriteLine(new string('=', title.Length + 4));
        Console.WriteLine($"  {title}");
        Console.WriteLine(new string('=', title.Length + 4));
    }
}
