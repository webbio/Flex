defmodule Flex.MapperTest do
  use ExUnit.Case
  alias Flex.Mapper
  alias Flex.Dummy.Book
  doctest Mapper

  setup do
    book = %Book{name: "Programming Elixir 1.3", author: "Dave Thomas", release_year: 2016}
    {:ok, book: book}
  end
  
  describe "to_doc" do
    test "implements a protocol to convert a data type to a Map for Elasticsearch", %{book: book} do
      assert %{name: "Programming Elixir 1.3", 
               author: "Dave Thomas", 
               year: 2016} = Mapper.to_doc(book)
    end
  end
end
