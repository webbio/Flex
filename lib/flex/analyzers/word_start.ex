defmodule Flex.Analyzers.WordStart do
  defmacro __using__(_opts) do
    quote do
      flex_analyzer :word_start, %{
        tokenizer: "word_start"
      }
      
      flex_tokenizer :word_start, %{
        type: "edge_ngram",
        min_gram: 2,
        max_gram: 20
      }
    end
  end
end