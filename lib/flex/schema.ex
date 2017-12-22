defmodule Flex.Schema do
  alias Flex.Index.{Mappings, Settings}
  alias Flex.{Schema, Mapper, Analyzers}
  
  defmacro __using__(_opts) do
    quote do
      @behaviour Mappings
      @behaviour Settings
      use Mapper
      
      @flex_settings %{}
      Module.register_attribute(__MODULE__, :flex_schema, accumulate: true)
      
      alias Flex.Analyzers
      import Schema      
    end
  end
  
  def parse_flex_field(name, type, opts \\ []), do: {name, type, opts}
  
  def parse_flex_block({:timestamps, _type, _opts}, fields) do
    {[{:field, [], [:inserted_at, :date]}, {:field, [], [:updated_at, :date]}], fields}
  end
  def parse_flex_block({:field, type, opts}, fields) do
    field = apply(__MODULE__, :parse_flex_field, opts)
    {{:flex_field, type, opts}, [field] ++ fields}
  end
  def parse_flex_block(ast, fields), do: {ast, fields}
  
  def add_analyzers(deps, %{analyzers: analyzers}) do
    deps ++ analyzers
    |> Enum.map(&to_string/1)
    |> Enum.filter(fn
      ("flex_" <> _) -> true
      (_) -> false
    end)
    |> Enum.map(fn ("flex_" <> analyzer) -> 
      Module.concat([Analyzers, Macro.camelize(analyzer)])
    end)
  end
  
  defmacro flex(name, [do: block]) do
    # prevent collisions with Ecto
    {block, schema} = Macro.prewalk(block, [], &parse_flex_block/2)
    {fields, mappings, meta} = parse_schema(schema)
    
    fields = Macro.escape(fields)
    mappings = Macro.escape(mappings)
    
    deps = []
    |> add_analyzers(meta)
    |> Enum.map(fn (dep) ->
      quote do: use unquote(dep)
    end)
    
    quote do
      unquote(block)
      unquote(deps)
      
      @flex_name unquote(name)
      @flex_fields unquote(fields)
      @flex_mappings unquote(mappings)
      
      def flex_fields(_),  do: @flex_fields
      def flex_mappings(), do: %{properties: @flex_mappings}
      def flex_name(),     do: @flex_name
      def flex_settings,   do: @flex_settings
      def create_index do
        Flex.Indexer.create_aliased_index(__MODULE__)
        Flex.Indexer.rebuild([], __MODULE__)
      end
    end
  end
  
  defmacro flex_analyzer(name, analyzer) do
    quote do
      put_setting %{
        analysis: %{
          analyzer: %{
            unquote(name) => unquote(analyzer)
          }
        }
      }
    end
  end
  
  defmacro flex_field(name, type, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :flex_schema, {unquote(name), unquote(type), unquote(opts)})
    end
  end
  
  defmacro flex_tokenizer(name, tokenizer) do
    quote do
      put_setting %{
        analysis: %{
          tokenizer: %{
            unquote(name) => unquote(tokenizer)
          }
        }
      }
    end
  end
  
  def flex_mappings(fields) do
    fields
    |> Enum.reduce({%{}, %{}}, fn({name, _, _} = field, {fields, meta}) ->
      {field, meta} = flex_mapping(field, meta)
      {Map.put(fields, name, field), meta}
    end)
  end
  
  def flex_mapping({_, type, opts}, meta), do: flex_mapping({%{type: type}, meta}, opts)
  def flex_mapping({field, meta}, [{option, [value | tl]} | opts]) do
    option
    |> handle_mapping_option({field, meta}, value)
    |> flex_mapping([{option, tl} | opts])
  end
  def flex_mapping({field, meta}, [{_option, []} | opts]), do: flex_mapping({field, meta}, opts)
  def flex_mapping({field, meta}, [{option, analyzer} | opts]), do: flex_mapping({field, meta}, [{option, [analyzer]} | opts])
  def flex_mapping({field, meta}, []), do: {field, meta}
  
  def handle_mapping_option(:analyzer, {field, meta}, analyzer) do
    meta = meta 
    |> Map.put(:analyzers, (meta[:analyzers] || []) ++ [analyzer])
    
    field = field 
    |> deep_merge(%{fields: %{analyzer => %{type: field.type, analyzer: analyzer}}})
    
    {field, meta}
  end
  
  def parse_schema(schema) do
    fields = schema 
    |> Enum.map(fn {field, _, _} -> field end) 
    |> Enum.reverse
    
    {mappings, meta} = flex_mappings(schema)
    {fields, mappings, meta}
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
  
  @doc false
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end
  defp deep_resolve(_key, _left, right) do
    right
  end
  
  @doc false
  defmacro put_setting(setting) do
    quote do
      flex_settings = @flex_settings
      |> deep_merge(unquote(setting))
      Module.put_attribute(__MODULE__, :flex_settings, flex_settings)
    end
  end
end