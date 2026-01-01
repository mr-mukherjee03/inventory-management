defmodule Inventory.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false, size: 255
      add :sku, :string, null: false, size: 100
      add :unit, :string, null: false, size: 20

      timestamps()
    end

    create unique_index(:items, [:sku], name: :items_sku_index)
    create index(:items, [:name])
    create constraint(:items, :valid_unit, check: "unit IN ('pcs', 'kg', 'litre')")
  end
end
