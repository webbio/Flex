defmodule Flex.Dummy.Book do
  defstruct [:name, :author, :release_year]
  
  @flex_mapping %{
    name: %{
      type: "text",
      analyzer: "flex_word_start"
    }
  }
  
  defimpl Flex.Mapper, for: __MODULE__ do
    @flex_fields [:name, :author, year: :release_year] 
    def to_doc(book), do: Flex.Mapper.Struct.to_doc(book, @flex_fields)
  end
  
  # mapping do
  #   field :name, :string, analyzer: :word_start
  #   field :author
  #   field :foo, :integer
  # end
  # 
  # def foo(book) do
  #   23
  # end
end

