using Lab01.Characters;

namespace Lab01.Effects;


public class RegenerationEffect : IEffect
{
    private readonly int healPerTurn;

    public string Name { get; }
    public int TurnsRemaining { get; private set; }
    public bool IsExpired => TurnsRemaining <= 0;

    public RegenerationEffect(string name, int healPerTurn, int turns)
    {
        Name = name;
        this.healPerTurn = healPerTurn;
        TurnsRemaining = turns;
    }

    public void OnApply(Character target)
    {
        Console.WriteLine($"   * {target.Name} gains '{Name}' (+{healPerTurn} HP/turn for {TurnsRemaining} turns).");
    }

    public void OnTick(Character target)
    {
        if (!target.IsAlive)
        {
            TurnsRemaining = 0;
            return;
        }

        Console.WriteLine($"   * '{Name}' restores {healPerTurn} HP to {target.Name}.");
        target.Heal(healPerTurn);
        TurnsRemaining--;
    }

    public void OnRemove(Character target)
    {
        Console.WriteLine($"   * Effect '{Name}' on {target.Name} has expired.");
    }
}
