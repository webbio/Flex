defmodule Flex.IndexerTest do
  use Flex.DataCase
  import Ecto.Query
  alias Flex.{Index, Indexer}
  alias Flex.Dummy.{Book, Repo}
  doctest Indexer
  
  defmodule BookWithWordMiddleAnalyzer do
    use Flex.Schema
    
    flex "books" do
      field :name, :text, analyzer: [:flex_word_start, :flex_word_middle]
      field :release_year, :integer
    end
  end
  
  defmodule BookWithoutReleaseYear do
    use Flex.Schema
    
    flex "books" do
      field :name, :text, analyzer: :flex_word_start
    end
  end
  
  describe "Indexing documents" do
    test "documents can be indexed to an elastic index" do
      books = insert_list(10, :book)
      books |> Indexer.index(Book)
      
      assert books_from_ecto() == books_from_elastic()
    end
    
    test "documents can be reindexed with new settings and/or mappings" do
      books = insert_list(10, :book)
      books |> Indexer.index(Book)
      
      assert find_book_by_name("Boo", "name.flex_word_start") |> has_hits()
      refute find_book_by_name("ook", "name.flex_word_start") |> has_hits()
      refute find_book_by_name("ook", "name.flex_word_middle") |> has_hits()
      
      Indexer.reindex(BookWithWordMiddleAnalyzer)
      
      assert find_book_by_name("Boo", "name.flex_word_start") |> has_hits()
      assert find_book_by_name("ook", "name.flex_word_middle") |> has_hits()
    end
    
    test "documents can be rebuild with new fields" do
      books = insert_list(10, :book)
      books |> Indexer.index(BookWithoutReleaseYear)
      
      assert books_from_ecto([:id, :name]) == books_from_elastic()
      
      books |> Indexer.rebuild(Book)
      
      assert books_from_ecto() == books_from_elastic()
    end
  end
  
  defp atomize_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
  
  defp books_from_ecto(fields \\ [:id, :name, :release_year]) do
    (from b in Book, select: map(b, ^fields))
    |> Repo.all
  end
  
  defp books_from_elastic do
    with {:ok, %{"hits" => %{"hits" => docs}}} <- Index.all(Book.flex_name())
    do
      docs
      |> Enum.map(&book_from_elastic/1)
      |> Enum.sort_by(&(&1.id))
    else
      []
    end
  end  
  
  defp book_from_elastic(%{"_id" => id, "_source" => source}) do
    source
    |> atomize_keys
    |> Map.merge(%{id: String.to_integer(id)})
  end 
  
  defp find_book_by_name(name, field) do
    Book.flex_name()
    |> Index.search(%{match: %{field => name}})
  end
  
  defp has_hits(result) do
    match? {:ok, %{"hits" => %{"hits" => [_|_]}}}, result
  end
  
  
end