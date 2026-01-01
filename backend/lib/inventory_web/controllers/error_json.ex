defmodule InventoryWeb.ErrorJSON do
  @moduledoc """
  JSON serialization for error responses.
  """

  @doc """
  Renders error responses based on the template.
  """
  def render("404.json", _assigns) do
    %{
      error: %{
        code: "not_found",
        message: "Resource not found"
      }
    }
  end

  def render("500.json", _assigns) do
    %{
      error: %{
        code: "internal_server_error",
        message: "Internal server error"
      }
    }
  end

  def render("insufficient_stock.json", _assigns) do
    %{
      error: %{
        code: "insufficient_stock",
        message: "Insufficient stock for this operation. Movement would result in negative stock."
      }
    }
  end

  def render("bad_request.json", %{message: message}) do
    %{
      error: %{
        code: "bad_request",
        message: message
      }
    }
  end

  def render("error.json", %{changeset: changeset}) do
    %{
      error: %{
        code: "validation_error",
        message: "Validation failed",
        details: translate_errors(changeset)
      }
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
