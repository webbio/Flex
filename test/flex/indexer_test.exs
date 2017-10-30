defmodule Flex.IndexerTest do
  use Flex.DataCase
  import Ecto.Query
  alias Flex.{Index, Indexer}
  alias Flex.Dummy.{Book, Repo}
  doctest Indexer
  
  describe "Indexing documents" do
    test "documents can be indexed to an elastic index" do
      books = insert_list(10, :book)
      books |> Indexer.index(Book)
      
      {:ok, %{"hits" => %{"hits" => docs}}} = Index.all(Book.flex_name())
            
      books_from_ecto = (from b in Book, select: map(b, [:id, :name, :release_year])) |> Repo.all
      
      books_from_elastic = docs
      |> Enum.map(&book_from_elastic/1)
      |> Enum.sort_by(&(&1.id))
      
      assert books_from_ecto == books_from_elastic
    end
  end
  
  defp book_from_elastic(%{"_id" => id, "_source" => source}) do
    s = for {key, val} <- source, into: %{}, do: {String.to_atom(key), val}
    Map.merge(s, %{id: id |> String.to_integer()})
  end
end