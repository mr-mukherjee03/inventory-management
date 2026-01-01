defmodule InventoryWeb.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/api", InventoryWeb do
    pipe_through :api

    # Item routes
    get "/items", ItemController, :index
    get "/items/:id", ItemController, :show
    post "/items", ItemController, :create

    # Movement routes
    post "/movements", MovementController, :create
    get "/movements", MovementController, :index
    get "/items/:item_id/movements", MovementController, :item_movements
  end
end
