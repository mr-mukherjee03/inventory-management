defmodule InventoryWeb.ItemController do
  use InventoryWeb, :controller

  alias Inventory
  
  require Logger

  action_fallback InventoryWeb.FallbackController

  @doc """
  Lists all items with their current stock levels.
  
  GET /api/items
  """
  def index(conn, _params) do
    Logger.info("ItemController.index - Listing all items")
    
    items = Inventory.list_items_with_stock()
    
    conn
    |> put_status(:ok)
    |> render(:index, items: items)
  end

  @doc """
  Shows a single item with its current stock.
  
  GET /api/items/:id
  """
  def show(conn, %{"id" => id}) do
    Logger.info("ItemController.show - Fetching item #{id}")
    
    with {:ok, item} <- Inventory.get_item_with_stock(id) do
      conn
      |> put_status(:ok)
      |> render(:show, item: item)
    end
  end

  @doc """
  Creates a new item.
  
  POST /api/items
  Body: {"name": "...", "sku": "...", "unit": "pcs|kg|litre"}
  """
  def create(conn, params) do
    Logger.info("ItemController.create - Creating new item")
    
    with {:ok, item} <- Inventory.create_item(params) do
      Logger.info("Item created successfully: #{item.id}")
      
      conn
      |> put_status(:created)
      |> render(:show, item: item)
    end
  end
end
