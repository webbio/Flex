defmodule Flex.Analyzers.WordMiddle do
  defmacro __using__(_opts) do
    quote do
      flex_analyzer :flex_word_middle, %{
        tokenizer: "flex_word_middle"
      }
      
      flex_tokenizer :flex_word_middle, %{
        type: "ngram",
        min_gram: 2,
        max_gram: 20
      }
    end
  end
end