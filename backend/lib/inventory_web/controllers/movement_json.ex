defmodule InventoryWeb.MovementJSON do
  @moduledoc """
  JSON serialization for Movement resources.
  """

  alias Inventory.Movement

  @doc """
  Renders a list of movements.
  """
  def index(%{movements: movements}) do
    %{data: for(movement <- movements, do: data(movement))}
  end

  @doc """
  Renders a single movement.
  """
  def show(%{movement: movement}) do
    %{data: data(movement)}
  end

  defp data(%Movement{} = movement) do
    base_data = %{
      id: movement.id,
      item_id: movement.item_id,
      quantity: movement.quantity,
      movement_type: movement.movement_type,
      created_at: movement.created_at
    }

    # Include item details if preloaded
    case movement.item do
      %Ecto.Association.NotLoaded{} -> base_data
      item -> Map.put(base_data, :item, item_data(item))
    end
  end

  defp item_data(item) do
    %{
      id: item.id,
      name: item.name,
      sku: item.sku,
      unit: item.unit
    }
  end
end
