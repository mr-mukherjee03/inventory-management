defmodule Inventory.Repo.Migrations.CreateInventoryMovements do
  use Ecto.Migration

  def change do
    create table(:inventory_movements) do
      add :item_id, references(:items, on_delete: :restrict), null: false
      add :quantity, :decimal, precision: 10, scale: 2, null: false
      add :movement_type, :string, null: false, size: 20
      add :created_at, :utc_datetime, null: false
    end

    create index(:inventory_movements, [:item_id])
    create index(:inventory_movements, [:created_at])
    create index(:inventory_movements, [:item_id, :movement_type])
    create constraint(:inventory_movements, :positive_quantity, check: "quantity > 0")
    create constraint(:inventory_movements, :valid_movement_type, check: "movement_type IN ('IN', 'OUT', 'ADJUSTMENT')")
  end
end
