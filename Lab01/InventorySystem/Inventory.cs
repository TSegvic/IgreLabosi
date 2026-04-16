using Lab01.Characters;
using Lab01.Items;

namespace Lab01.InventorySystem;


public class Inventory
{
    private readonly List<Item> items = new();

    public double MaxWeight { get; }

    public double CurrentWeight => items.Sum(i => i.Weight);

    public int Count => items.Count;

    public IReadOnlyList<Item> Items => items;

    public Inventory(double maxWeight = 50.0)
    {
        if (maxWeight <= 0)
            throw new ArgumentException("Maximum weight must be positive.", nameof(maxWeight));
        MaxWeight = maxWeight;
    }

    public bool AddItem(Item item)
    {
        if (CurrentWeight + item.Weight > MaxWeight)
        {
            Console.WriteLine($"! Inventory is full. Cannot add '{item.Name}' ({item.Weight} kg).");
            return false;
        }

        items.Add(item);
        return true;
    }

 
    public bool RemoveItem(Item item) => items.Remove(item);


    public bool UseItem(Item item, Character user)
    {
        if (!items.Contains(item))
        {
            Console.WriteLine($"! Item '{item.Name}' is not in the inventory.");
            return false;
        }

        if (item is IConsumable consumable)
        {
            consumable.Consume(user);
            items.Remove(item);
            return true;
        }

        Console.WriteLine($"! Item '{item.Name}' cannot be used (not consumable).");
        return false;
    }

 
    public T? FindFirst<T>() where T : Item =>
        items.OfType<T>().FirstOrDefault();

    public void PrintContents()
    {
        Console.WriteLine($"   Inventory ({CurrentWeight:0.##}/{MaxWeight:0.##} kg, {items.Count} items):");
        if (items.Count == 0)
        {
            Console.WriteLine("     (empty)");
            return;
        }

        foreach (var item in items)
            Console.WriteLine($"     - {item.Name} ({item.Weight} kg) - {item.Description}");
    }
}
