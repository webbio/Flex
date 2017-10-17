defmodule Flex.Schema do
  alias Flex.Index.{Mappings, Settings}
  alias Flex.{Schema, Mapper}
  
  defmacro __using__(_opts) do
    quote do
      @behaviour Mappings
      @behaviour Settings
      use Mapper
      
      import Schema
      
      @flex_config %{fields: %{}, mappings: %{}, settings: %{}}
      def flex_mappings,  do: flex_config().mappings
      def flex_settings,  do: flex_config().settings
      def flex_fields(_), do: flex_config().fields |> Map.keys
    end
  end
  
  defmacro flex([do: block]) do
    # prevent collisions with Ecto
    block = Macro.prewalk(block, fn
      {:field, type, opts} -> {:flex_field, type, opts}
      node -> node
    end)

    quote do
      unquote(block)
      def flex_config(), do: @flex_config
    end
  end
  
  defmacro flex_analyzer(name, analyzer) do
    quote do
      flex_config = @flex_config 
      |> deep_merge(%{settings: %{analysis: %{analyzer: %{unquote(name) => unquote(analyzer)}}}})
      Module.put_attribute(__MODULE__, :flex_config, flex_config)
    end
  end
  
  defmacro flex_field(name, type, opts \\ []) do
    quote do
      flex_config = @flex_config 
      |> deep_merge(%{fields: %{unquote(name) => %{type: unquote(type), opts: unquote(opts)}}})
      Module.put_attribute(__MODULE__, :flex_config, flex_config)
    end
  end
  
  defmacro flex_tokenizer(name, tokenizer) do
    quote do
      flex_config = @flex_config 
      |> deep_merge(%{settings: %{analysis: %{tokenizer: %{unquote(name) => unquote(tokenizer)}}}})
      Module.put_attribute(__MODULE__, :flex_config, flex_config)
    end
  end
  
  @doc """
  Perform a deep merge of two maps
  
  ## Example
  
    iex> left = %{foo: %{bar: 1}}
    ...> right = %{foo: %{quux: 1}}
    ...> Flex.Schema.deep_merge(left, right)
    %{foo: %{bar: 1, quux: 1}}
  """
  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end
  defp deep_resolve(_key, _left, right) do
    right
  end
end