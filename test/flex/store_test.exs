defmodule Flex.StoreTest do
  use Flex.DataCase
  alias Flex.{Document, Index, Store}
  alias Flex.Dummy.{Book, Repo}
  doctest Store
  
  @book_attrs %{name: "Programming Elixir 1.3", release_year: 2016}

  describe "The Flex Store" do
    @tag :store
    test "insert a document with Ecto and Elastic in a transaction" do
      {:ok, book} = %Book{}
      |> Book.changeset(@book_attrs)
      |> Store.insert(Repo)
      
      assert_is_same_book Repo.get!(Book, book.id), Document.get("books", book.id)
    end
    
    @tag :store
    test "the transaction is halted if elastic yields an error" do
      Index.create "books"
      Index.close "books"
      
      assert {:error, _} = %Book{}
      |> Book.changeset(@book_attrs)
      |> Store.insert(Repo)
      
      Index.open "books"
      Index.refresh "books"
      
      assert Repo.all(Book) == []
      assert {:ok, %{"hits" => %{"hits" => []}}} = Index.all("books")
    end
    
    @tag :store
    test "update a document with Ecto and Elastic in a transaction" do
      {:ok, book} = %Book{}
      |> Book.changeset(@book_attrs)
      |> Store.insert(Repo)
      
      {:ok, book} = book
      |> Book.changeset(%{name: "Programming Elixir 1.5"})
      |> Store.update(Repo)
      
      assert_is_same_book Repo.get!(Book, book.id), Document.get("books", book.id)
    end
    
    @tag :store
    test "delete a document with Ecto and Elastic in a transaction" do
      {:ok, book} = %Book{}
      |> Book.changeset(@book_attrs)
      |> Store.insert(Repo)
      
      {:ok, book} = book
      |> Store.delete(Repo)
      
      refute Repo.get(Book, book.id)
      assert {:error, :not_found} = Document.get("books", book.id)
    end
  end
  
  defp assert_is_same_book(book, {:ok, %{"_id" => id, "_source" => source}}) do
    assert book.id == id |> String.to_integer
    assert book.name == source["name"]
    assert book.release_year == source["release_year"]
  end
end
