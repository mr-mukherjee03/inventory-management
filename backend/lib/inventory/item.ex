defmodule Inventory.Item do
  @moduledoc """
  Schema and changeset for Item entity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  @valid_units ~w(pcs kg litre)
  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :id

  schema "items" do
    field :name, :string
    field :sku, :string
    field :unit, :string
    field :current_stock, :decimal, virtual: true

    has_many :movements, Inventory.Movement

    timestamps()
  end

  @doc """
  Changeset for creating or updating an item.
  """

  def changeset(item, attrs) do
    Logger.debug("Creating changeset for item with attrs: #{inspect(attrs)}")
    
    item
    |> cast(attrs, [:name, :sku, :unit])
    |> validate_required([:name, :sku, :unit], message: "is required")
    |> validate_length(:name, min: 1, max: 255, message: "must be between 1 and 255 characters")
    |> validate_length(:sku, min: 1, max: 100, message: "must be between 1 and 100 characters")
    |> validate_inclusion(:unit, @valid_units, message: "must be one of: #{Enum.join(@valid_units, ", ")}")
    |> validate_format(:sku, ~r/^[A-Z0-9\-_]+$/i, message: "must contain only letters, numbers, hyphens, and underscores")
    |> unique_constraint(:sku, name: :items_sku_index, message: "has already been taken")
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    if changeset.valid? do
      Logger.debug("Item changeset is valid")
      changeset
    else
      Logger.warning("Item changeset validation failed: #{inspect(changeset.errors)}")
      changeset
    end
  end

  @doc """
  Returns the list of valid units.
  """
  def valid_units, do: @valid_units

  @doc """
  Adds computed stock to an item struct.
  """
  def with_stock(item, stock) do
    %{item | current_stock: stock}
  end
end
