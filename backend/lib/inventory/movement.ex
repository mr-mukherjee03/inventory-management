defmodule Inventory.Movement do
  @moduledoc """
  Schema and changeset for Inventory Movement entity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  @movement_types ~w(IN OUT ADJUSTMENT)
  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :id

  schema "inventory_movements" do
    field :quantity, :decimal
    field :movement_type, :string
    field :created_at, :utc_datetime

    belongs_to :item, Inventory.Item
  end

  @doc """
  Changeset for creating a new movement.
  """

  def changeset(movement, attrs) do
    Logger.debug("Creating changeset for movement with attrs: #{inspect(attrs)}")
    
    movement
    |> cast(attrs, [:item_id, :quantity, :movement_type, :created_at])
    |> validate_required([:item_id, :quantity, :movement_type], message: "is required")
    |> validate_number(:quantity, greater_than: 0, message: "must be greater than 0")
    |> validate_inclusion(:movement_type, @movement_types, 
         message: "must be one of: #{Enum.join(@movement_types, ", ")}")
    |> foreign_key_constraint(:item_id, message: "item does not exist")
    |> put_created_at()
    |> validate_changeset()
  end

  defp put_created_at(changeset) do
    case get_field(changeset, :created_at) do
      nil -> put_change(changeset, :created_at, DateTime.utc_now() |> DateTime.truncate(:second))
      _ -> changeset
    end
  end

  defp validate_changeset(changeset) do
    if changeset.valid? do
      Logger.debug("Movement changeset is valid")
      changeset
    else
      Logger.warning("Movement changeset validation failed: #{inspect(changeset.errors)}")
      changeset
    end
  end

  @doc """
  Returns the list of valid movement types.
  """
  def movement_types, do: @movement_types

  @doc """
  Returns true if the movement type increases stock (IN or positive ADJUSTMENT).
  """
  def increases_stock?(%__MODULE__{movement_type: "IN"}), do: true
  def increases_stock?(%__MODULE__{movement_type: "ADJUSTMENT", quantity: qty}) when qty > 0, do: true
  def increases_stock?(_), do: false

  @doc """
  Returns true if the movement type decreases stock (OUT or negative ADJUSTMENT).
  """
  def decreases_stock?(%__MODULE__{movement_type: "OUT"}), do: true
  def decreases_stock?(%__MODULE__{movement_type: "ADJUSTMENT", quantity: qty}) when qty < 0, do: true
  def decreases_stock?(_), do: false
end
