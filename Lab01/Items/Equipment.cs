using Lab01.Characters;

namespace Lab01.Items;


public abstract class Equipment : Item, IEquippable
{
    protected Equipment(string name, string description, double weight)
        : base(name, description, weight)
    {
    }

    public abstract void Equip(Character character);

    public abstract void Unequip(Character character);
}


public class Weapon : Equipment
{
    public int AttackBonus { get; }

    public Weapon(string name, int attackBonus, double weight = 3.0)
        : base(name, $"Weapon (+{attackBonus} ATK).", weight)
    {
        AttackBonus = attackBonus;
    }

    public override void Equip(Character character)
    {
        Console.WriteLine($"> {character.Name} equips '{Name}' (+{AttackBonus} ATK).");
    }

    public override void Unequip(Character character)
    {
        Console.WriteLine($"> {character.Name} unequips '{Name}'.");
    }
}


public class Armor : Equipment
{
    public int DefenseBonus { get; }

    public Armor(string name, int defenseBonus, double weight = 5.0)
        : base(name, $"Armor (+{defenseBonus} DEF).", weight)
    {
        DefenseBonus = defenseBonus;
    }

    public override void Equip(Character character)
    {
        Console.WriteLine($"> {character.Name} equips '{Name}' (+{DefenseBonus} DEF).");
    }

    public override void Unequip(Character character)
    {
        Console.WriteLine($"> {character.Name} unequips '{Name}'.");
    }
}
