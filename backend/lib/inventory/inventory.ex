defmodule Inventory do

  import Ecto.Query, warn: false
  alias Inventory.Repo
  alias Inventory.{Item, Movement, StockCalculator}
  
  require Logger

  @doc """
  Returns the list of all items with their current stock levels.
  """

  def list_items_with_stock do
    Logger.info("Fetching all items with stock")
    
    items = Repo.all(Item) |> Repo.preload(:movements)
    
    items_with_stock = Enum.map(items, fn item ->
      stock = StockCalculator.calculate_stock(item.movements)
      Item.with_stock(item, stock)
    end)
    
    Logger.info("Retrieved #{length(items_with_stock)} items")
    items_with_stock
  end

  @doc """
  Gets a single item with its current stock.
  """

  def get_item_with_stock(id) do
    Logger.info("Fetching item with id: #{id}")
    
    case Repo.get(Item, id) do
      nil ->
        Logger.warning("Item not found: #{id}")
        {:error, :not_found}
      
      item ->
        item = Repo.preload(item, :movements)
        stock = StockCalculator.calculate_stock(item.movements)
        {:ok, Item.with_stock(item, stock)}
    end
  end

  @doc """
  Creates a new item.
  """

  def create_item(attrs \\ %{}) do
    Logger.info("Creating new item with attrs: #{inspect(attrs)}")
    
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, item} ->
        Logger.info("Item created successfully: #{item.id} - #{item.sku}")
        {:ok, Item.with_stock(item, Decimal.new("0"))}
      
      {:error, changeset} ->
        Logger.error("Failed to create item: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  @doc """
  Updates an item.
  """
  def update_item(%Item{} = item, attrs) do
    Logger.info("Updating item: #{item.id}")
    
    item
    |> Item.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_item} ->
        Logger.info("Item updated successfully: #{updated_item.id}")
        {:ok, updated_item}
      
      {:error, changeset} ->
        Logger.error("Failed to update item: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  @doc """
  Deletes an item.
  """
  def delete_item(%Item{} = item) do
    Logger.info("Deleting item: #{item.id}")
    
    Repo.delete(item)
    |> case do
      {:ok, deleted_item} ->
        Logger.info("Item deleted successfully: #{deleted_item.id}")
        {:ok, deleted_item}
      
      {:error, changeset} ->
        Logger.error("Failed to delete item: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

 
  @doc """
  Records a new inventory movement.
  """
  def record_movement(attrs \\ %{}) do
    Logger.info("Recording movement: #{inspect(attrs)}")
    
    # Use transaction to ensure consistency
    Repo.transaction_with_logging(fn ->
      with {:ok, item_id} <- validate_item_id(attrs),
           {:ok, item} <- fetch_item_with_movements(item_id),
           {:ok, movement_attrs} <- prepare_movement_attrs(attrs),
           {:ok, _new_stock} <- validate_stock_level(item, movement_attrs),
           {:ok, movement} <- insert_movement(movement_attrs) do
        Logger.info("Movement recorded successfully: #{movement.id}")
        movement
      else
        {:error, reason} = error ->
          Logger.error("Failed to record movement: #{inspect(reason)}")
          Repo.rollback(reason)
          error
      end
    end)
    |> case do
      {:ok, movement} -> {:ok, movement}
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_item_id(%{item_id: item_id}) when not is_nil(item_id), do: {:ok, item_id}
  defp validate_item_id(%{"item_id" => item_id}) when not is_nil(item_id), do: {:ok, item_id}
  defp validate_item_id(_), do: {:error, :item_id_required}
  
  defp fetch_item_with_movements(item_id) do
    case Repo.get(Item, item_id) do
      nil -> {:error, :not_found}
      item -> {:ok, Repo.preload(item, :movements)}
    end
  end

  defp prepare_movement_attrs(attrs) do
    movement_attrs = 
      attrs
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
    
    {:ok, movement_attrs}
  rescue
    ArgumentError -> {:error, :invalid_attributes}
  end

  defp validate_stock_level(item, %{movement_type: movement_type, quantity: quantity}) do
    current_stock = StockCalculator.calculate_stock(item.movements)
    
    quantity_decimal = 
      case quantity do
        %Decimal{} = d -> d
        n when is_number(n) -> Decimal.new(to_string(n))
        s when is_binary(s) -> Decimal.new(s)
      end
    
    case StockCalculator.validate_movement(current_stock, movement_type, quantity_decimal) do
      {:ok, new_stock} -> {:ok, new_stock}
      {:error, _msg} -> {:error, :insufficient_stock}
    end
  end

  defp insert_movement(attrs) do
    %Movement{}
    |> Movement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the movement history for a specific item.
  """

  def get_movement_history(item_id) do
    Logger.info("Fetching movement history for item: #{item_id}")
    
    case Repo.get(Item, item_id) do
      nil ->
        Logger.warning("Item not found: #{item_id}")
        {:error, :not_found}
      
      _item ->
        movements = 
          Movement
          |> where([m], m.item_id == ^item_id)
          |> order_by([m], desc: m.created_at)
          |> Repo.all()
        
        Logger.info("Retrieved #{length(movements)} movements for item #{item_id}")
        {:ok, movements}
    end
  end

  @doc """
  Lists all movements across all items.
  """
  
  def list_movements do
    Logger.info("Fetching all movements")
    
    movements = 
      Movement
      |> order_by([m], desc: m.created_at)
      |> Repo.all()
      |> Repo.preload(:item)
    
    Logger.info("Retrieved #{length(movements)} movements")
    movements
  end
end
