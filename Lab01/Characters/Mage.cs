using Lab01.Effects;

namespace Lab01.Characters;

public class Mage : Character
{
    private const int FireballCost = 30;
    private const double FireballDamageMultiplier = 1.6;
    private const int BurnDamagePerTurn = 6;
    private const int BurnTurns = 2;
    private const int ManaRegenPerTurn = 10;

    public override string ClassName => "Mage";

    public override string ResourceName => "Mana";

    public override string SpecialAbilityName => "Fireball";

    public override int SpecialAbilityCost => FireballCost;

    public Mage(string name)
        : base(name, maxHealth: 90, attack: 12, defense: 6, maxResource: 120)
    {
    }

    public override void UseSpecialAbility(Character target)
    {
        if (Resource < FireballCost)
        {
            Console.WriteLine(
                $"! {Name} does not have enough Mana for Fireball " +
                $"(needs {FireballCost}, has {Resource}). Falling back to basic attack.");
            Attack(target);
            return;
        }

        Resource -= FireballCost;

        // Magical damage ignores half of the target's defense.
        int damage = Math.Max(1, (int)(AttackPower * FireballDamageMultiplier) - target.Defense / 2);
        Console.WriteLine($"> {Name} casts FIREBALL on {target.Name} (-{FireballCost} Mana): {damage} magical damage!");
        target.TakeDamage(damage);

        // Apply the burn (multi-turn) effect to the surviving target.
        if (target.IsAlive)
            target.AddEffect(new DamageOverTimeEffect("Burn", BurnDamagePerTurn, BurnTurns));
    }

    public override void OnTurnStart()
    {
        base.OnTurnStart();
        if (!IsAlive) return;

        if (Resource < MaxResource)
        {
            int before = Resource;
            Resource += ManaRegenPerTurn;
            Console.WriteLine($"   {Name} regenerates {Resource - before} Mana (now {Resource}/{MaxResource}).");
        }
    }
}
