defmodule Inventory.InventoryTest do
  use Inventory.DataCase

  alias Inventory

  describe "items" do
    test "create_item/1 creates an item" do
      attrs = %{name: "Test Item", sku: "TEST-001", unit: "pcs"}
      
      assert {:ok, item} = Inventory.create_item(attrs)
      assert item.name == "Test Item"
      assert item.sku == "TEST-001"
    end

    test "list_items_with_stock/0 returns items with stock" do
      {:ok, _item} = Inventory.create_item(%{name: "Item", sku: "SKU-001", unit: "pcs"})
      
      items = Inventory.list_items_with_stock()
      
      assert length(items) == 1
      assert hd(items).current_stock == Decimal.new("0")
    end
  end

  describe "movements - negative stock rejection" do
    setup do
      {:ok, item} = Inventory.create_item(%{name: "Item", sku: "SKU-001", unit: "pcs"})
      %{item: item}
    end

    test "rejects OUT movement with insufficient stock", %{item: item} do
      attrs = %{item_id: item.id, quantity: 100, movement_type: "OUT"}
      
      assert {:error, :insufficient_stock} = Inventory.record_movement(attrs)
    end

    test "allows movement with sufficient stock", %{item: item} do
      {:ok, _} = Inventory.record_movement(%{item_id: item.id, quantity: 100, movement_type: "IN"})
      
      attrs = %{item_id: item.id, quantity: 50, movement_type: "OUT"}
      
      assert {:ok, movement} = Inventory.record_movement(attrs)
      assert movement.quantity == Decimal.new("50")
    end

    test "stock is calculated correctly after movements", %{item: item} do
      {:ok, _} = Inventory.record_movement(%{item_id: item.id, quantity: 100, movement_type: "IN"})
      {:ok, _} = Inventory.record_movement(%{item_id: item.id, quantity: 30, movement_type: "OUT"})
      
      {:ok, item_with_stock} = Inventory.get_item_with_stock(item.id)
      
      assert Decimal.equal?(item_with_stock.current_stock, Decimal.new("70"))
    end
  end
end
