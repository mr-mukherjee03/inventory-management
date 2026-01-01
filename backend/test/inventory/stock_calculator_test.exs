defmodule Inventory.StockCalculatorTest do
  use ExUnit.Case, async: true

  alias Inventory.StockCalculator
  alias Inventory.Movement

  describe "calculate_stock/1" do
    test "calculates stock with IN movements" do
      movements = [
        %Movement{movement_type: "IN", quantity: Decimal.new("100")},
        %Movement{movement_type: "IN", quantity: Decimal.new("50")}
      ]

      assert StockCalculator.calculate_stock(movements) == Decimal.new("150")
    end

    test "calculates stock with OUT movements" do
      movements = [
        %Movement{movement_type: "IN", quantity: Decimal.new("100")},
        %Movement{movement_type: "OUT", quantity: Decimal.new("30")}
      ]

      assert StockCalculator.calculate_stock(movements) == Decimal.new("70")
    end

    test "calculates stock with ADJUSTMENT movements" do
      movements = [
        %Movement{movement_type: "IN", quantity: Decimal.new("100")},
        %Movement{movement_type: "ADJUSTMENT", quantity: Decimal.new("-10")}
      ]

      assert StockCalculator.calculate_stock(movements) == Decimal.new("90")
    end
  end

  describe "validate_movement/3 - negative stock rejection" do
    test "rejects OUT movement that would cause negative stock" do
      current_stock = Decimal.new("50")
      
      assert {:error, _message} = 
        StockCalculator.validate_movement(current_stock, "OUT", Decimal.new("100"))
    end

    test "allows OUT movement with sufficient stock" do
      current_stock = Decimal.new("100")
      
      assert {:ok, new_stock} = 
        StockCalculator.validate_movement(current_stock, "OUT", Decimal.new("50"))
      
      assert new_stock == Decimal.new("50")
    end

    test "rejects ADJUSTMENT that would cause negative stock" do
      current_stock = Decimal.new("50")
      
      assert {:error, _message} = 
        StockCalculator.validate_movement(current_stock, "ADJUSTMENT", Decimal.new("-100"))
    end
  end
end
