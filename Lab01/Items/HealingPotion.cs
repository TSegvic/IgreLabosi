using Lab01.Characters;

namespace Lab01.Items;


public class HealingPotion : Item, IConsumable
{
    private readonly int healAmount;

    public HealingPotion(string name, int healAmount, double weight = 0.5)
        : base(name, $"Restores {healAmount} HP instantly.", weight)
    {
        this.healAmount = healAmount;
    }

    public void Consume(Character user)
    {
        Console.WriteLine($"> {user.Name} uses '{Name}'.");
        user.Heal(healAmount);
    }
}
