using Lab01.Characters;

namespace Lab01.Effects;


public interface IEffect
{
    string Name { get; }

    int TurnsRemaining { get; }

    bool IsExpired { get; }

  
    void OnApply(Character target);


    void OnTick(Character target);


    void OnRemove(Character target);
}
