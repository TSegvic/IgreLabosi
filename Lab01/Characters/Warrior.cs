namespace Lab01.Characters;


public class Warrior : Character
{
    private const int RagePerAttack = 15;
    private const int RagePerDamageTaken = 10;
    private const int MightyStrikeCost = 40;
    private const double MightyStrikeMultiplier = 2.0;

    public override string ClassName => "Warrior";

    public override string ResourceName => "Rage";

    public override string SpecialAbilityName => "Mighty Strike";

    public override int SpecialAbilityCost => MightyStrikeCost;

    public Warrior(string name)
        : base(name, maxHealth: 140, attack: 18, defense: 12, maxResource: 100)
    {
        // Warriors start with 0 Rage and build it up during combat.
        Resource = 0;
    }

    public override void UseSpecialAbility(Character target)
    {
        if (Resource < MightyStrikeCost)
        {
            Console.WriteLine(
                $"! {Name} does not have enough Rage for Mighty Strike " +
                $"(needs {MightyStrikeCost}, has {Resource}). Falling back to basic attack.");
            Attack(target);
            return;
        }

        Resource -= MightyStrikeCost;
        int damage = Math.Max(1, (int)(AttackPower * MightyStrikeMultiplier) - target.Defense);
        Console.WriteLine($"> {Name} uses MIGHTY STRIKE on {target.Name} (-{MightyStrikeCost} Rage): {damage} damage!");
        target.TakeDamage(damage);
    }

    protected override void OnAttackPerformed(Character target, int damageDealt)
    {
        if (!IsAlive) return;

        int before = Resource;
        Resource += RagePerAttack;
        Console.WriteLine($"   {Name} gains {Resource - before} Rage (now {Resource}/{MaxResource}).");
    }

    protected override void OnDamageTaken(int amount)
    {
        if (!IsAlive) return;

        int before = Resource;
        Resource += RagePerDamageTaken;
        Console.WriteLine($"   {Name} gains {Resource - before} Rage from the pain (now {Resource}/{MaxResource}).");
    }
}
