defmodule InventoryWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use Phoenix.Controller

  require Logger

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    Logger.warning("Validation error: #{inspect(changeset.errors)}")
    
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: InventoryWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    Logger.warning("Resource not found")
    
    conn
    |> put_status(:not_found)
    |> put_view(json: InventoryWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :insufficient_stock}) do
    Logger.warning("Insufficient stock for movement")
    
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: InventoryWeb.ErrorJSON)
    |> render(:insufficient_stock)
  end

  def call(conn, {:error, :item_id_required}) do
    Logger.warning("Item ID required but not provided")
    
    conn
    |> put_status(:bad_request)
    |> put_view(json: InventoryWeb.ErrorJSON)
    |> render(:bad_request, message: "item_id is required")
  end

  def call(conn, {:error, reason}) do
    Logger.error("Unhandled error: #{inspect(reason)}")
    
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: InventoryWeb.ErrorJSON)
    |> render(:"500")
  end
end
