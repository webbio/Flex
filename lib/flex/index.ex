defmodule Flex.Index do
  @moduledoc """
  This module provides an interface for working with indexes
  """
  alias Flex.API
  
  def analyze(index, analyzer, text), do: [index, "_analyze"] |> make_path |> API.post(%{analyzer: analyzer, text: text})
  
  def search(index, query), do: [index, "_search"] |> make_path |> API.post(query)
  
  def all(index), do: [index, "_search"] |> make_path |> API.post(%{query: %{match_all: %{}}})
  
  def close(index), do: [index, "_close"] |> make_path |> API.post
  def open(index), do: [index, "_open"] |> make_path |> API.post
  def reindex(index), do: [index, "_update_by_query?pretty&refresh&conflicts=proceed"] |> make_path |> API.post
  
  def aliases(actions), do: ["_aliases"] |> make_path |> API.post(%{"actions" => actions})
  
  def rotate_to(index, new_index) do
    with {:ok, old_index} <- index |> current_alias()
    do
      aliases [
        %{add: %{index: new_index, alias: index}},
        %{remove_index: %{index: old_index}},
      ]
      refresh(index)
    else
      err -> err
    end    
  end
  
  def current_alias(index) do
    with {:ok, info} <- index |> info()
    do
      {:ok, info 
      |> Map.keys() 
      |> List.first()}
    else
      err -> err
    end
  end
  
  def current_alias!(index) do
    with {:ok, current_alias} <- current_alias(index) 
    do
      current_alias
    else
      _ -> raise "index has no alias"
    end
  end
  
  @doc """
  Get information about an index
  
  ## Elastic Docs
  
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-index.html

  ## Examples

      iex> Flex.Index.info "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Flex.Index.create "elastic_test_index"
      ...> {:ok, %{"elastic_test_index" => info}} = Flex.Index.info "elastic_test_index"
      ...> with %{"aliases" => _, "mappings" => _, "settings" => _} <- info, do: :passed
      :passed
  """
  def info(index), do: index |> make_path |> API.get

  @doc """
  Create a new index
  
  ## Elastic Docs
      
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html

  ## Examples

     iex> Flex.Index.create "elastic_test_index"
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
     iex> Flex.Index.create "elastic_test_index"
     {:error, :index_already_exists_exception}

     iex> Flex.Index.create "elastic_test_index", %{settings: %{number_of_shards: 3}}
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
  """
  def create(index, options \\ %{}) do
    index |> make_path |> API.put(options)
  end

  @doc """
  Checks if an index exists
  
  ## Elastic Docs
  
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-exists.html

  ## Examples

      iex> Flex.Index.exists? "elastic_test_index"
      {:ok, false}

      iex> Flex.Index.create "elastic_test_index"
      ...> Flex.Index.exists? "elastic_test_index"
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
  
  ## Elastic Docs
  
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-delete-index.html

  ## Examples

      iex> Flex.Index.delete "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Flex.Index.create "elastic_test_index"
      ...> Flex.Index.delete "elastic_test_index"
      {:ok, %{"acknowledged" => true}}
  """
  def delete(index) do
    index |> make_path |> API.delete
  end
  
  @doc """
  Deletes all indexes
  
  ## Examples
      
      iex> Flex.index.create "foo"
      ...> Flex.index.create "bar"
      ...> {Flex.Index.exists?("foo"), Flex.Index.exists?("bar")}
      {true, true}
      iex> Flex.Index.delete_all()
      ...> {Flex.Index.exists?("foo"), Flex.Index.exists?("bar")}
      {false, false}
  """
  def delete_all, do: delete "*"
  
  @doc """
  Refreshes an index
  
  ## Elastic Docs
  
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html  
  """
  
  def refresh(index), do: [index, "_refresh"] |> make_path() |> API.post()

  @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end