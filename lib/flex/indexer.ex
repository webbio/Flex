defmodule Flex.Indexer do
  alias Flex.{API, Index}
  
  def index([doc | _] = docs), do: index(docs, doc.__struct__.flex_schema())
  def index(docs, schema) do
    {:ok, info} = create_aliased_index(schema)
    index_name = info |> Map.keys() |> List.first()
    IO.inspect(index_name)
    bulk_index(docs, index_name, schema)
    Index.refresh(index_name)
  end
  
  def create_aliased_index(schema) do
    with {:ok, exists?} <- Index.exists?(schema.flex_name()) 
    do
      create_aliased_index(schema, exists?)
    else
      err -> err
    end
  end      
  def create_aliased_index(schema, true), do: Index.info(schema.flex_name())
  def create_aliased_index(schema, false) do
    {name, aliases} = index_config(schema.flex_name())
    Index.create(name, %{settings: schema.flex_settings(), mappings: %{name => schema.flex_mappings()}} |> Map.merge(aliases))
    Index.info(schema.flex_name())
  end
  
  defp bulk_index(docs, index_name, schema) do
    docs
    |> Flow.from_enumerable()
    |> Flow.map(fn doc ->
      [%{index: %{_id: doc.id}}, schema.to_doc(doc)]
    end)
    |> batch(500)
    |> Flow.map_state(fn lines ->
      Enum.reduce(lines, "", fn (line, payload) ->
        payload <> Poison.encode!(line) <> "\n"
      end)
    end)
    |> Flow.each_state(fn bulk ->
      API.post "/#{index_name}/#{index_name}/_bulk", bulk
    end)
    |> Flow.run
  end
  
  def batch(flow, count) do
    flow
    |> Flow.partition(window: Flow.Window.count(count))
    |> Flow.reduce(fn -> [] end, fn line, lines -> line ++ lines end)
  end
  
  
  defp index_config(name) do
    {postfix_with_timestamp(name), %{aliases: %{name => %{}}}}
  end
  
  defp postfix_with_timestamp(name) do
    DateTime.utc_now()
    |> DateTime.to_unix 
    |> to_string()
    |> List.wrap()
    |> List.insert_at(0, name)
    |> Enum.join("_")
  end
end