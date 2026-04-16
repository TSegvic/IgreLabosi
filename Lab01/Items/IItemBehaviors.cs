using Lab01.Characters;

namespace Lab01.Items;


public interface IConsumable
{
    void Consume(Character user);
}


public interface IEquippable
{
    void Equip(Character character);
    void Unequip(Character character);
}
