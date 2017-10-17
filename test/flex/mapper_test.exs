defmodule Flex.MapperTest do
  use ExUnit.Case
  alias Flex.Mapper
  doctest Mapper
  
  setup do
    book = %{name: "Programming Elixir 1.3", author: "Dave Thomas", release_year: 2016}
    {:ok, book: book}
  end
    
  describe "include Flex.Mapper as a behaviour" do
    defmodule BookAsBehaviour do
      defstruct [:name, :author, :release_year]
      @behaviour Mapper
      
      def to_doc(book) do
        %{name: book.name, 
          author: book.author,
          year: book.release_year,
          author_bio: author_bio(book)}
      end
      
      defp author_bio(_book) do
        "bio"
      end
    end
    
    test "to_doc/1 defines a valid map", %{book: book} do
      assert BookAsBehaviour |> defines_valid_map_for(book)
    end
  end
  
  describe "include Flex.Mapper with use and flex_fields/1 implementation" do
    defmodule BookAsUseWithFn do
      defstruct [:name, :author, :release_year]
      use Flex.Mapper
      
      def flex_fields(_book), do: [:name, :author, :author_bio, year: :release_year]
      
      def author_bio(_book) do
        "bio"
      end
    end
    
    test "to_doc/1 defines a valid map", %{book: book} do
      assert BookAsUseWithFn |> defines_valid_map_for(book)
    end
  end
  
  describe "include Flex.Mapper with use and pass fields as option" do
    defmodule BookAsUseWithOptions do
      defstruct [:name, :author, :release_year]
      use Flex.Mapper,
        fields: [:name, :author, :author_bio, year: :release_year]
      
      def author_bio(_book) do
        "bio"
      end
    end
    
    test "to_doc/1 defines a valid map", %{book: book} do
      assert BookAsUseWithOptions |> defines_valid_map_for(book)
    end
  end
  
  defp defines_valid_map_for(mod, data) do
    %{name: "Programming Elixir 1.3", 
             author: "Dave Thomas", 
             year: 2016,
             author_bio: "bio"} = mod |> struct(data) |> mod.to_doc
  end
end

