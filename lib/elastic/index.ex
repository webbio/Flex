defmodule Elastic.Index do
  @moduledoc """
  This module provides an interface for working with indexes
  """
  alias Elastic.API

#  def all(index), do: [index, "_search"] |> make_path |> HTTP.post(%{query: %{match_all: %{}}})

  @doc """
  Get information about an index

  ## Examples

      iex> Elastic.Index.info "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Elastic.Index.create "elastic_test_index"
      ...> {:ok, %{"elastic_test_index" => info}} = Elastic.Index.info "elastic_test_index"
      ...> with %{"aliases" => _, "mappings" => _, "settings" => _} <- info, do: :passed
      :passed
  """
  def info(index), do: index |> make_path |> API.get

  @doc """
  Create a new index

  ## Examples

     iex> Elastic.Index.create "elastic_test_index"
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
     iex> Elastic.Index.create "elastic_test_index"
     {:error, :index_already_exists_exception}

     iex> Elastic.Index.create "elastic_test_index", %{settings: %{number_of_shards: 3}}
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
  """
  def create(index, options \\ %{}) do
    index |> make_path |> API.put(options)
  end

  @doc """
  Checks if an index exists

  ## Examples

      iex> Elastic.Index.exists? "elastic_test_index"
      {:ok, false}

      iex> Elastic.Index.create "elastic_test_index"
      ...> Elastic.Index.exists? "elastic_test_index"
      {:ok, true}
  """
  def exists?(index) do
    with {:ok, _} <- index |> make_path |> API.head
    do
      {:ok, true}
    else
      {:error, :not_found} -> {:ok, false}
      err -> err
    end
  end

  @doc """
  Deletes an index

  ## Examples

      iex> Elastic.Index.delete "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Elastic.Index.create "elastic_test_index"
      ...> Elastic.Index.delete "elastic_test_index"
      {:ok, %{"acknowledged" => true}}
  """
  def delete(index) do
    index |> make_path |> API.delete
  end

  @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end