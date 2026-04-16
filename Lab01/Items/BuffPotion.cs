using Lab01.Characters;
using Lab01.Effects;

namespace Lab01.Items;


public class BuffPotion : Item, IConsumable
{
    private readonly Func<IEffect> effectFactory;

    public BuffPotion(string name, string description, double weight, Func<IEffect> effectFactory)
        : base(name, description, weight)
    {
        this.effectFactory = effectFactory;
    }

    public void Consume(Character user)
    {
        Console.WriteLine($"> {user.Name} uses '{Name}'.");
        user.AddEffect(effectFactory());
    }
}
