defmodule Flex.Index do
  @moduledoc """
  This module provides an interface for working with indexes
  """
  alias Flex.API

  def analyze(index, analyzer, text),
    do: [index, "_analyze"] |> make_path |> API.post(%{analyzer: analyzer, text: text})

  def search(index, query), do: search(index, index, query)
  def search(index, type, query), do: [index, type, "_search"] |> make_path |> API.post(query)

  def count(index, query), do: count(index, index, query)
  def count(index, type, query), do: [index, type, "_count"] |> make_path |> API.post(query)

  def delete_by_query(index, query), do: delete_by_query(index, index, query)

  def delete_by_query(index, type, query),
    do: [index, type, "_query"] |> make_path |> API.delete(query)

  def info(), do: API.get("")

  def version() do
    with {:ok, info} <- info() do
      info |> version()
    else
      err -> err
    end
  end

  def version(%{"version" => %{"number" => version}}), do: version

  def version_as_float do
    version()
    |> String.split(".")
    |> Enum.take(2)
    |> Enum.join(".")
    |> String.to_float()
  end

  def all(index), do: [index, "_search"] |> make_path |> API.post(%{query: %{match_all: %{}}})

  def scroll(
        index,
        type,
        query \\ %{size: 5_000, query: %{match_all: %{}}}
      )

  def scroll(index, type, query) when is_map(query) do
    [index, type, "_search?scroll=10s&search_type=scan&fields="] |> make_path
    |> API.post(query)
  end

  def scroll(scroll_id) do
    ["_search", "scroll", "#{scroll_id}?scroll=10s"] |> make_path |> API.get()
  end

  def forcemerge(index), do: [index, "_forcemerge?max_num_segments=5"] |> make_path |> API.post()

  def find(index, id), do: find(index, index, id)
  def find(index, type, id), do: [index, type, id, "_source"] |> make_path |> API.get()

  def close(index), do: [index, "_close"] |> make_path |> API.post()
  def open(index), do: [index, "_open"] |> make_path |> API.post()

  def reindex(index),
    do: [index, "_update_by_query?pretty&refresh&conflicts=proceed"] |> make_path |> API.post()

  def aliases(actions), do: ["_aliases"] |> make_path |> API.post(%{"actions" => actions})

  def rotate_to(index, new_index) do
    with {:ok, old_index} <- index |> current_alias() do
      rotate_to(index, new_index, old_index)
    else
      err -> err
    end
  end

  def rotate_to(index, new_index, new_index), do: refresh(index)

  def rotate_to(index, new_index, old_index) do
    aliases([
      %{add: %{index: new_index, alias: index}},
      %{remove: %{index: old_index, alias: index}}
    ])

    delete(old_index)
    refresh(index)
  end

  def stale(index) do
    with {:ok, indexes} <- info("#{index}*"),
         {:ok, current_alias} <- current_alias(index) do
      (indexes |> Map.keys()) -- [current_alias]
    else
      err -> err
    end
  end

  def delete_stale(index) do
    stale(index)
    |> Enum.map(&delete/1)
  end

  def current_alias(index) do
    with {:ok, info} <- index |> info() do
      {:ok,
       info
       |> Map.keys()
       |> List.first()}
    else
      err -> err
    end
  end

  def current_alias!(index) do
    with {:ok, current_alias} <- current_alias(index) do
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
  def info(index), do: index |> make_path |> API.get()

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
    with {:ok, _} <- index |> make_path |> API.head() do
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
    index |> make_path |> API.delete()
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
  def delete_all, do: delete("*")

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
