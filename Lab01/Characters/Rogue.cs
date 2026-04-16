namespace Lab01.Characters;


public class Rogue : Character
{
    private const int BackstabCost = 35;
    private const double BackstabNormalMultiplier = 1.7;
    private const double BackstabCritMultiplier = 2.5;
    private const double CritChance = 0.5;
    private const int EnergyRegenPerTurn = 15;
    private const double DodgeChance = 0.25;

    private readonly Random rng;

    public override string ClassName => "Rogue";

    public override string ResourceName => "Energy";

    public override string SpecialAbilityName => "Backstab";

    public override int SpecialAbilityCost => BackstabCost;

   
    public Rogue(string name, int? seed = null)
        : base(name, maxHealth: 100, attack: 16, defense: 8, maxResource: 100)
    {
        rng = seed.HasValue ? new Random(seed.Value) : new Random();
    }

    public override void UseSpecialAbility(Character target)
    {
        if (Resource < BackstabCost)
        {
            Console.WriteLine(
                $"! {Name} does not have enough Energy for Backstab " +
                $"(needs {BackstabCost}, has {Resource}). Falling back to basic attack.");
            Attack(target);
            return;
        }

        Resource -= BackstabCost;

        bool isCritical = rng.NextDouble() < CritChance;
        double multiplier = isCritical ? BackstabCritMultiplier : BackstabNormalMultiplier;
        int damage = Math.Max(1, (int)(AttackPower * multiplier) - target.Defense);
        string critTag = isCritical ? " - CRITICAL HIT!" : "";

        Console.WriteLine($"> {Name} uses BACKSTAB on {target.Name} (-{BackstabCost} Energy){critTag}: {damage} damage!");
        target.TakeDamage(damage);
    }

    public override void TakeDamage(int amount)
    {
        if (amount > 0 && rng.NextDouble() < DodgeChance)
        {
            Console.WriteLine($"   {Name} DODGES the attack! (chance {DodgeChance:P0})");
            return;
        }

        base.TakeDamage(amount);
    }

    public override void OnTurnStart()
    {
        base.OnTurnStart();
        if (!IsAlive) return;

        if (Resource < MaxResource)
        {
            int before = Resource;
            Resource += EnergyRegenPerTurn;
            Console.WriteLine($"   {Name} restores {Resource - before} Energy (now {Resource}/{MaxResource}).");
        }
    }
}
