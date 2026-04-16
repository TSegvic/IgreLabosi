using Lab01.Characters;

namespace Lab01.Effects;


public class StatBuffEffect : IEffect
{
    private readonly int attackBonus;
    private readonly int defenseBonus;

    public string Name { get; }
    public int TurnsRemaining { get; private set; }
    public bool IsExpired => TurnsRemaining <= 0;

    public StatBuffEffect(string name, int attackBonus, int defenseBonus, int turns)
    {
        Name = name;
        this.attackBonus = attackBonus;
        this.defenseBonus = defenseBonus;
        TurnsRemaining = turns;
    }

    public void OnApply(Character target)
    {
        target.AttackModifier += attackBonus;
        target.DefenseModifier += defenseBonus;

        var parts = new List<string>();
        if (attackBonus != 0) parts.Add(FormatBonus(attackBonus, "ATK"));
        if (defenseBonus != 0) parts.Add(FormatBonus(defenseBonus, "DEF"));
        Console.WriteLine($"   * {target.Name} gains effect '{Name}' ({string.Join(", ", parts)}) for {TurnsRemaining} turns.");
    }

    public void OnTick(Character target)
    {
        TurnsRemaining--;
    }

    public void OnRemove(Character target)
    {
        target.AttackModifier -= attackBonus;
        target.DefenseModifier -= defenseBonus;
        Console.WriteLine($"   * Effect '{Name}' on {target.Name} has expired.");
    }

    private static string FormatBonus(int value, string stat) =>
        $"{(value > 0 ? "+" : "")}{value} {stat}";
}
