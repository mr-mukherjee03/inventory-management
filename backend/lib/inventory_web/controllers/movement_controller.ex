defmodule InventoryWeb.MovementController do
  use InventoryWeb, :controller

  alias Inventory
  
  require Logger

  action_fallback InventoryWeb.FallbackController

  @doc """
  Records a new inventory movement.
  
  POST /api/movements
  Body: {"item_id": 1, "quantity": 100, "movement_type": "IN|OUT|ADJUSTMENT"}
  """
  def create(conn, params) do
    Logger.info("MovementController.create - Recording new movement")
    
    with {:ok, movement} <- Inventory.record_movement(params) do
      Logger.info("Movement recorded successfully: #{movement.id}")
      
      # Preload item for response
      movement = Inventory.Repo.preload(movement, :item)
      
      conn
      |> put_status(:created)
      |> render(:show, movement: movement)
    end
  end

  @doc """
  Lists all movements across all items.
  
  GET /api/movements
  """
  def index(conn, _params) do
    Logger.info("MovementController.index - Listing all movements")
    
    movements = Inventory.list_movements()
    
    conn
    |> put_status(:ok)
    |> render(:index, movements: movements)
  end

  @doc """
  Gets movement history for a specific item.
  
  GET /api/items/:item_id/movements
  """
  def item_movements(conn, %{"item_id" => item_id}) do
    Logger.info("MovementController.item_movements - Fetching movements for item #{item_id}")
    
    with {:ok, movements} <- Inventory.get_movement_history(item_id) do
      conn
      |> put_status(:ok)
      |> render(:index, movements: movements)
    end
  end
end
