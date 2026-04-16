# Interactive RPG Battle System

A console-based RPG battle simulator built with .NET 8 and object-oriented programming principles.

## Features

- Choose between Warrior, Mage, and Rogue
- Turn-based combat system
- Interactive combat menu
- Unique special abilities for each class
- Enemy AI system
- Weapons, armor, and consumable items
- Buff and healing effects
- Inventory system with weight limits

## Project Structure

```
Lab01/
- Characters/
  - Character.cs
  - Warrior.cs
  - Mage.cs
  - Rogue.cs
- Combat/
  - Battle.cs
  - EnemyAi.cs
  - Game.cs
- Effects/
- InventorySystem/
- Items/
- Program.cs
```

## Architecture

### Character System
`Character.cs` is the abstract base class for all character types.

Each class overrides:
- `UseSpecialAbility()`
- `SpecialAbilityName`
- `SpecialAbilityCost`
- `ResourceName`

### Combat System
- `Game.cs` handles menus, game setup, and the turn loop.
- `EnemyAi.cs` controls enemy behavior.
- `Battle.cs` contains combat helper methods.

### Items and Effects
- Weapons and armor provide permanent stat bonuses.
- Potions provide healing, resource restoration, or temporary buffs.
- Effects can apply over multiple turns.

## Running the Project

Requires .NET 8 SDK or newer.

```bash
dotnet run --project Lab01.csproj
```
