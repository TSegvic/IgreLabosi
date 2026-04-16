using Lab01.Effects;
using Lab01.InventorySystem;
using Lab01.Items;

namespace Lab01.Characters;


public abstract class Character
{
   

    public string Name { get; }

    public abstract string ClassName { get; }


    private int health;

    public int MaxHealth { get; protected set; }

    public int Health
    {
        get => health;
        protected set => health = Math.Clamp(value, 0, MaxHealth);
    }

    public bool IsAlive => Health > 0;



    public int BaseAttack { get; protected set; }

    public int BaseDefense { get; protected set; }


    public int AttackModifier { get; set; }

   
    public int DefenseModifier { get; set; }

    public int AttackPower =>
        Math.Max(0, BaseAttack + AttackModifier + (EquippedWeapon?.AttackBonus ?? 0));

    public int Defense =>
        Math.Max(0, BaseDefense + DefenseModifier + (EquippedArmor?.DefenseBonus ?? 0));

   
    //  Class resource (Rage / Mana / Energy / ...)
   

    private int resource;

    public abstract string ResourceName { get; }
    public abstract string SpecialAbilityName { get; }

    public abstract int SpecialAbilityCost { get; }


    public int MaxResource { get; protected set; }

    public int Resource
    {
        get => resource;
        protected set => resource = Math.Clamp(value, 0, MaxResource);
    }

  

    public Weapon? EquippedWeapon { get; private set; }

    public Armor? EquippedArmor { get; private set; }

    public Inventory Inventory { get; }


    private readonly List<IEffect> effects = new();

    public IReadOnlyList<IEffect> ActiveEffects => effects;



    protected Character(
        string name,
        int maxHealth,
        int attack,
        int defense,
        int maxResource,
        double inventoryCapacity = 50)
    {
        Name = name;
        MaxHealth = maxHealth;
        health = maxHealth;
        BaseAttack = attack;
        BaseDefense = defense;
        MaxResource = maxResource;
        resource = maxResource;
        Inventory = new Inventory(inventoryCapacity);
    }

  
    public abstract void UseSpecialAbility(Character target);

    public virtual void Attack(Character target)
    {
        int damage = Math.Max(1, AttackPower - target.Defense);
        Console.WriteLine($"> {Name} attacks {target.Name} for {damage} damage.");
        target.TakeDamage(damage);
        OnAttackPerformed(target, damage);
    }

    public virtual void TakeDamage(int amount)
    {
        if (amount <= 0) return;

        Health -= amount;
        Console.WriteLine($"   {Name}: HP {Health}/{MaxHealth}" + (IsAlive ? "" : "  [DEFEATED]"));
        OnDamageTaken(amount);
    }

    public virtual void Heal(int amount)
    {
        if (amount <= 0 || !IsAlive) return;

        int before = Health;
        Health += amount;
        int actual = Health - before;
        Console.WriteLine($"   {Name} recovers {actual} HP (HP {Health}/{MaxHealth}).");
    }

    public virtual void RestoreResource(int amount)
    {
        if (amount <= 0) return;

        int before = Resource;
        Resource += amount;
        int actual = Resource - before;
        Console.WriteLine($"   {Name} restores {actual} {ResourceName} ({ResourceName} {Resource}/{MaxResource}).");
    }


    protected virtual void OnAttackPerformed(Character target, int damageDealt)
    {
    }

   
    protected virtual void OnDamageTaken(int amount)
    {
    }

    

    public void EquipWeapon(Weapon weapon)
    {
        EquippedWeapon?.Unequip(this);
        EquippedWeapon = weapon;
        weapon.Equip(this);
    }

    public void EquipArmor(Armor armor)
    {
        EquippedArmor?.Unequip(this);
        EquippedArmor = armor;
        armor.Equip(this);
    }

    

    public void AddEffect(IEffect effect)
    {
        effects.Add(effect);
        effect.OnApply(this);
    }

    public void TickEffects()
    {
        foreach (var effect in effects.ToList())
        {
            effect.OnTick(this);
            if (effect.IsExpired)
            {
                effect.OnRemove(this);
                effects.Remove(effect);
            }
        }
    }


    public virtual void OnTurnStart()
    {
        TickEffects();
    }



    public virtual void PrintStatus()
    {
        Console.WriteLine(
            $"[{ClassName,-7}] {Name,-14} HP {Health,3}/{MaxHealth,-3} | " +
            $"{ResourceName,-6} {Resource,3}/{MaxResource,-3} | " +
            $"ATK {AttackPower,2} | DEF {Defense,2}");

        if (EquippedWeapon != null || EquippedArmor != null)
        {
            var parts = new List<string>();
            if (EquippedWeapon != null) parts.Add($"weapon: {EquippedWeapon.Name}");
            if (EquippedArmor != null) parts.Add($"armor: {EquippedArmor.Name}");
            Console.WriteLine($"            - {string.Join(", ", parts)}");
        }

        if (effects.Count > 0)
        {
            var fx = effects.Select(e => $"{e.Name}({e.TurnsRemaining})");
            Console.WriteLine($"            - effects: {string.Join(", ", fx)}");
        }
    }
}
