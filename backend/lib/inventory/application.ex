defmodule Inventory.Application do
  @moduledoc """
  The Inventory Application.

  This module defines the supervision tree for the application,
  managing the lifecycle of all critical processes.
  """

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Inventory Management System...")

    children = [
      InventoryWeb.Telemetry,
      Inventory.Repo,
      {Phoenix.PubSub, name: Inventory.PubSub},
      InventoryWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Inventory.Supervisor]
    
    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        Logger.info("Inventory Management System started successfully")
        {:ok, pid}
      
      {:error, reason} ->
        Logger.error("Failed to start Inventory Management System: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    InventoryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
