using Lab01.Characters;

namespace Lab01.Effects;


public class DamageOverTimeEffect : IEffect
{
    private readonly int damagePerTurn;

    public string Name { get; }
    public int TurnsRemaining { get; private set; }
    public bool IsExpired => TurnsRemaining <= 0;

    public DamageOverTimeEffect(string name, int damagePerTurn, int turns)
    {
        Name = name;
        this.damagePerTurn = damagePerTurn;
        TurnsRemaining = turns;
    }

    public void OnApply(Character target)
    {
        Console.WriteLine($"   * {target.Name} is afflicted with '{Name}' ({damagePerTurn} damage/turn for {TurnsRemaining} turns).");
    }

    public void OnTick(Character target)
    {
        if (!target.IsAlive)
        {
            TurnsRemaining = 0;
            return;
        }

        Console.WriteLine($"   * '{Name}' deals {damagePerTurn} damage to {target.Name}.");
        target.TakeDamage(damagePerTurn);
        TurnsRemaining--;
    }

    public void OnRemove(Character target)
    {
        Console.WriteLine($"   * Effect '{Name}' on {target.Name} has expired.");
    }
}
