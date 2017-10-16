defmodule Flex.Mapping do
  @moduledoc """
  This module provides an interface for working with mappings
  """
  alias Flex.API


  @doc """
  Put a mapping

  ## Examples

     iex> mappings = %{properties:
     ...>   %{name:
     ...>     %{type: "text"}
     ...>    }
     ...> }
     ...> Flex.Mapping.put "elastic_test_index", mappings
     {:ok, %{"acknowledged" => true}}
     iex> more_mappings = %{properties:
     ...>   %{age:
     ...>     %{type: "integer"}
     ...>    }
     ...> }
     ...> Flex.Mapping.put "elastic_test_index", more_mappings
     iex> Flex.Mapping.get "elastic_test_index"
     {:ok, %{"properties" => %{ "name" => %{"type" => "text"}, "age" => %{"type" => "integer"} } }}
  """
  def put(index, %{} = mappings) do
    [index, :_mapping, index] |> make_path |> API.put(mappings)
  end

  @doc """
  Get a mapping

  ## Examples

     iex> mappings = %{properties:
     ...>   %{name:
     ...>     %{type: "text"}
     ...>    }
     ...> }
     ...> Flex.Mapping.put "elastic_test_index", mappings
     iex> Flex.Mapping.get "elastic_test_index"
     {:ok, %{"properties" => %{"name" => %{"type" => "text"} } }}
  """
  def get(index) do
    with {:ok, %{^index => %{"mappings" => %{^index => mappings}}}} <- [index, :_mapping, index] |> make_path |> API.get
    do
      {:ok, mappings}
    else
      err -> err
    end
  end

 @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end