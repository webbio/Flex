defmodule Flex.Analyzers.WordStart do
  defmacro __using__(_opts) do
    quote do
      flex_analyzer(:flex_word_start, %{
        tokenizer: "flex_word_start",
        filter: "lowercase"
      })

      flex_tokenizer(:flex_word_start, %{
        type: "edge_ngram",
        min_gram: 2,
        max_gram: 20
      })
    end
  end
end
