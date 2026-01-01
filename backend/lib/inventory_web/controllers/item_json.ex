defmodule InventoryWeb.ItemJSON do
  @moduledoc """
  JSON serialization for Item resources.
  """

  alias Inventory.Item

  @doc """
  Renders a list of items.
  """
  def index(%{items: items}) do
    %{data: for(item <- items, do: data(item))}
  end

  @doc """
  Renders a single item.
  """
  def show(%{item: item}) do
    %{data: data(item)}
  end

  defp data(%Item{} = item) do
    %{
      id: item.id,
      name: item.name,
      sku: item.sku,
      unit: item.unit,
      current_stock: item.current_stock,
      inserted_at: item.inserted_at,
      updated_at: item.updated_at
    }
  end
end
