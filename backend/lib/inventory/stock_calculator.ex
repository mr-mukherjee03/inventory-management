defmodule Inventory.StockCalculator do
  @moduledoc """
  Business logic module for stock calculations.
  Stock = sum(IN) - sum(OUT) ± ADJUSTMENT
  """

  alias Inventory.Movement
  require Logger

  @doc """
  Calculates the current stock for an item based on its movements.
  """

  def calculate_stock(movements) when is_list(movements) do
    Logger.debug("Calculating stock from #{length(movements)} movements")
    
    stock = Enum.reduce(movements, Decimal.new("0"), fn movement, acc ->
      calculate_movement_impact(movement, acc)
    end)
    
    Logger.debug("Calculated stock: #{stock}")
    stock
  end


  defp calculate_movement_impact(%Movement{movement_type: "IN", quantity: qty}, current_stock) do
    Decimal.add(current_stock, qty)
  end

  defp calculate_movement_impact(%Movement{movement_type: "OUT", quantity: qty}, current_stock) do
    Decimal.sub(current_stock, qty)
  end

  defp calculate_movement_impact(%Movement{movement_type: "ADJUSTMENT", quantity: qty}, current_stock) do

    Decimal.add(current_stock, qty)
  end

  @doc """
  Validates that a proposed movement will not result in negative stock.
  """

  def validate_movement(current_stock, movement_type, quantity) do
    Logger.debug("Validating movement: type=#{movement_type}, quantity=#{quantity}, current_stock=#{current_stock}")
    
    new_stock = calculate_new_stock(current_stock, movement_type, quantity)
    
    cond do
      Decimal.negative?(new_stock) ->
        error_msg = "Insufficient stock. Current: #{current_stock}, Requested: #{quantity}"
        Logger.warning("Movement validation failed: #{error_msg}")
        {:error, error_msg}
      
      true ->
        Logger.debug("Movement validation passed. New stock will be: #{new_stock}")
        {:ok, new_stock}
    end
  end

  @doc """
  Calculates what the new stock would be after applying a movement.
  """

  def calculate_new_stock(current_stock, "IN", quantity) do
    Decimal.add(current_stock, quantity)
  end

  def calculate_new_stock(current_stock, "OUT", quantity) do
    Decimal.sub(current_stock, quantity)
  end

  def calculate_new_stock(current_stock, "ADJUSTMENT", quantity) do
    Decimal.add(current_stock, quantity)
  end

  def calculate_new_stock(current_stock, _invalid_type, _quantity) do
    current_stock
  end

  @doc """
  Checks if a stock level is valid (non-negative).
  """
  
  def valid_stock?(stock) do
    not Decimal.negative?(stock)
  end
end
