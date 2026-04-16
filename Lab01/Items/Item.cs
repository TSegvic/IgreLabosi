namespace Lab01.Items;


public abstract class Item
{
    public string Name { get; }
    public string Description { get; }
    public double Weight { get; }

    protected Item(string name, string description, double weight)
    {
        Name = name;
        Description = description;
        Weight = weight;
    }

    public override string ToString() => $"{Name} ({Weight} kg)";
}
