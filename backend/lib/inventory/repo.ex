defmodule Inventory.Repo do
  use Ecto.Repo,
    otp_app: :inventory,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Logs transaction start and completion for debugging purposes.
  """
  
  def transaction_with_logging(fun, opts \\ []) do
    require Logger
    Logger.debug("Starting database transaction")
    
    result = transaction(fun, opts)
    
    case result do
      {:ok, value} ->
        Logger.debug("Transaction completed successfully")
        {:ok, value}
      
      {:error, reason} ->
        Logger.warning("Transaction failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
