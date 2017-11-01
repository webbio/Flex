defmodule Flex.Dummy.Book do
  use Ecto.Schema
  import Ecto.Changeset
  use Flex.Schema
  alias Flex.Dummy.Book
  
  schema "books" do
    field :name, :string
    field :release_year, :integer

    timestamps()
  end
    
  flex "books" do
    field :name, :text, analyzer: :flex_word_start
    field :release_year, :integer
  end
  
  @doc false
  def changeset(%Book{} = book, attrs) do
    book
    |> cast(attrs, [:name, :release_year])
    |> validate_required([:name, :release_year])
  end
end