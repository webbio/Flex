defmodule Flex.SchemaTest do
  use ExUnit.Case
  alias Flex.{Analyzers, Schema}
  doctest Schema
  
  @settings_fixture  %{
    analysis: %{
      analyzer: %{
        word_start: %{
          tokenizer: "word_start"
        }
      },
      tokenizer: %{
        word_start: %{
          max_gram: 20, 
          min_gram: 2,
          type: "edge_ngram"
        }
      }
    }
  }
  
  defmodule Book do
    defstruct [:name, :release_year]
    
    use Schema
    use Analyzers.WordStart
        
    flex do
      field :name, :text, analyzer: :word_start
      field :release_year, :integer
    end
  end
  
  describe "define a Flex Schema for a struct" do
    test "all properties can be set with the flex macro" do
      assert %{} = Book.flex_mappings()
      assert @settings_fixture = Book.flex_settings()
      assert %{name: "Programming Elixir 1.3", release_year: 2016} 
             = Book.to_doc(%Book{name: "Programming Elixir 1.3", release_year: 2016}) 
    end
  end
end