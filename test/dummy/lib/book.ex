defmodule Flex.Dummy.Book do
  use Ecto.Schema
  use Flex.Schema
  
  schema "books" do
    field :name, :string
    field :release_year, :integer

    timestamps()
  end
    
  flex "books" do
    field :name, :text, analyzer: :flex_word_start
    field :release_year, :integer
  end
end