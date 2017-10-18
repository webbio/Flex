defmodule Flex.Schema do
  alias Flex.Index.{Mappings, Settings}
  alias Flex.{Schema, Mapper}
  
  defmacro __using__(_opts) do
    quote do
      @behaviour Mappings
      @behaviour Settings
      use Mapper
      
      import Schema
      
      @flex_config %{mappings: %{}, settings: %{}}
      Module.register_attribute(__MODULE__, :flex_schema, accumulate: true)
      # def flex_mappings,  do: flex_config() |> flex_mappings()
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
      def flex_mappings(), do: flex_mappings(@flex_schema)
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
      Module.put_attribute(__MODULE__, :flex_schema, {unquote(name), unquote(type), unquote(opts)})
    end
  end
  
  defmacro flex_tokenizer(name, tokenizer) do
    quote do
      flex_config = @flex_config 
      |> deep_merge(%{settings: %{analysis: %{tokenizer: %{unquote(name) => unquote(tokenizer)}}}})
      Module.put_attribute(__MODULE__, :flex_config, flex_config)
    end
  end
  
  def flex_mappings(fields) do
    for {name, _, _} = field <- fields, into: %{}, do: {name, flex_mapping(field)}
  end
  
  def flex_mapping({_, type, opts}), do: flex_mapping(%{type: type}, opts)
  def flex_mapping(field, [{option, [value | tl]} | opts]) do
    option
    |> handle_mapping_option(field, value)
    |> flex_mapping([{option, tl} | opts])
  end
  def flex_mapping(field, [{option, []} | opts]), do: flex_mapping(field, opts)
  def flex_mapping(field, [{option, analyzer} | opts]), do: flex_mapping(field, [{option, [analyzer]} | opts])
  def flex_mapping(field, [[] | opts]), do: flex_mapping(field, opts)
  def flex_mapping(field, []), do: field
  
  def handle_mapping_option(:analyzer, field, analyzer) do
    field 
    |> deep_merge(%{fields: %{analyzer => %{type: field.type, analyzer: analyzer}}})
  end
  
  
  # def flex_mappings([field | tl]) do
  #   flex_mapping(field) ++ flex_mappings(tl)
  # end
  # def flex_mapping(%{analyzer: analyzer} = field) when not is_nil(analyzer) do
  #    field 
  #    |> flex_mapping(%{opts: %{analyzers: [analyzer], analyzer: nil}})
  # end
  # def flex_mapping(%{analyzers: [analyzer | tl]} = field) do
  #   field 
  #   |> flex_mapping(%{fields: %{analyzer => %{type: field.type, analyzer: analyzer}}, opts: %{analyzers: tl}})
  # end
  # def flex_mapping(%{analyzers: [analyzer]} = field) do
  #   field
  #   |> flex_mapping(%{fields: %{analyzer => %{type: field.type, analyzer: analyzer}}})
  # end
  # def flex_mapping(%{analyzers: []} = field) do
  #   field
  #   |> flex_mapping(%{fields: %{raw: %{type: "keyword", analyzer: analyzer}}})
  # end
  # def flex_mapping(field, merge), do: field |> deep_merge(merge) |> flex_mapping()
  # def flex_mapping(field), do: field
  #   
  # 
  # def flex_mapping_fields(type, %{analyzers: [_|_]}) do
  #   flex_mapping_fields(type, %{}) ++ for analyzer <- opts.analyzers, into: %{}, do:
  #     
  # end
  
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