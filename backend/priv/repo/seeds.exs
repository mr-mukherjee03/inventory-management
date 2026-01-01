# Script for populating the database

alias Inventory.Repo
alias Inventory.Item

require Logger

Logger.info("Seeding database...")

# Create sample items
items = [
  %{name: "Onions", sku: "ONI-001", unit: "kg"},
  %{name: "Potato", sku: "POT-002", unit: "kg"},
  %{name: "Milk", sku: "MIL-003", unit: "litre"},
  %{name: "Boxes", sku: "BOX-004", unit: "pcs"}
]

Enum.each(items, fn item_attrs ->
  case Repo.get_by(Item, sku: item_attrs.sku) do
    nil ->
      %Item{}
      |> Item.changeset(item_attrs)
      |> Repo.insert!()
      Logger.info("Created item: #{item_attrs.sku}")
    
    _existing ->
      Logger.info("Item already exists: #{item_attrs.sku}")
  end
end)

Logger.info("Seeding completed!")
