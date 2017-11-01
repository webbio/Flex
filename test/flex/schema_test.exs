defmodule Flex.SchemaTest do
  use ExUnit.Case
  alias Flex.Schema
  doctest Schema
  
  @fields_fixture [:name, :release_year]
  @mappings_fixture %{
    properties: %{
      name: %{
        fields: %{
          flex_word_start: %{
            analyzer: :flex_word_start,
            type: :text
          }
        }, 
        type: :text
      },
      release_year: %{
        type: :integer
      }
    }
  }
  @settings_fixture  %{
    analysis: %{
      analyzer: %{
        flex_word_start: %{
          tokenizer: "flex_word_start"
        }
      },
      tokenizer: %{
        flex_word_start: %{
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
    
    flex "books" do
      field :name, :text, analyzer: :flex_word_start
      field :release_year, :integer
    end
  end
  
  describe "define a Flex Schema for a struct" do
    test "all properties can be set with the flex macro" do
      assert @fields_fixture   == Book.flex_fields(true)
      assert @mappings_fixture == Book.flex_mappings()
      assert @settings_fixture == Book.flex_settings()
    end
  end
end