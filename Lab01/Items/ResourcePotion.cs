using Lab01.Characters;

namespace Lab01.Items;


public class ResourcePotion : Item, IConsumable
{
    private readonly int restoreAmount;

    public ResourcePotion(string name, int restoreAmount, double weight = 0.5)
        : base(name, $"Restores {restoreAmount} resource points.", weight)
    {
        this.restoreAmount = restoreAmount;
    }

    public void Consume(Character user)
    {
        Console.WriteLine($"> {user.Name} uses '{Name}'.");
        user.RestoreResource(restoreAmount);
    }
}
