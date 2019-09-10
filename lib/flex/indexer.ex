defmodule Flex.Indexer do
  alias Flex.{API, Index, Mapping, Setting}

  def index([doc | _] = docs), do: index(docs, doc.__struct__)

  def index(docs, schema) do
    {:ok, info} = create_aliased_index(schema)
    index_name = info |> Map.keys() |> List.first()
    bulk_index(docs, index_name, schema)
    Index.refresh(index_name)
  end

  def reindex(schema) do
    with {:ok, info} <- schema.flex_name() |> Index.info(),
         index <- info |> Map.keys() |> List.first(),
         {:ok, _} <- index |> Index.close(),
         {:ok, _} <- index |> Setting.put(schema.flex_settings()),
         {:ok, _} <- index |> Index.open(),
         {:ok, _} <- index |> Mapping.put(schema.flex_mappings()) do
      index |> Index.reindex()
    else
      err -> err
    end
  end

  def rebuild([doc | _] = docs), do: rebuild(docs, doc.__struct__)

  def rebuild(docs, schema) do
    with index_name <- schema.flex_name() |> postfix_with_timestamp(),
         type_name <- schema.flex_type() || schema.flex_name(),
         {:ok, _} <-
           index_name
           |> Index.create(%{
             settings: schema.flex_settings(),
             mappings: %{type_name => schema.flex_mappings()}
           }),
         _ <- docs |> bulk_index(index_name, schema) do
      schema.flex_name() |> Index.rotate_to(index_name)
    else
      err -> err
    end
  end

  def create_aliased_index(schema) do
    case Index.exists?(schema.flex_name()) do
      {:ok, exists?} ->
        create_aliased_index(schema, exists?)

      {:error, :not_found} ->
        create_aliased_index(schema, false)

      err ->
        err
    end
  end

  def create_aliased_index(schema, true), do: Index.info(schema.flex_name())

  def create_aliased_index(schema, false),
    do: create_aliased_index(schema, schema.flex_type() || schema.flex_name(), false)

  def create_aliased_index(schema, type, false) do
    create_timestamped_index(schema, type, true)
  end

  def create_timestamped_index(schema), do: create_timestamped_index(schema, schema.flex_type())

  def create_timestamped_index(schema, type, with_alias \\ false) do
    {name, aliases} = index_config(schema.flex_name())
    options =
      %{settings: schema.flex_settings(), mappings: %{type => schema.flex_mappings()}}
      |> maybe_add_aliases(aliases, with_alias)

    Index.create(
      name,
      options
    )

    case with_alias do
      true -> Index.info(schema.flex_name())
      false -> Index.info(name)
    end
  end

  # Flex.Indexer.create_aliased_index(Ivy.PackageOffers.Schema)
  # Ivy.Import.start_all; Ivy.PackageOffers.Process.start

  def bulk_update(docs, index_name, schema), do: bulk_index(docs, index_name, index_name, schema, true)

  def bulk_update(flow, index_name, type_name, schema, _opts), do: bulk_index(flow, index_name, type_name, schema, [], true)

  def bulk_index([], _, _), do: :ok

  def bulk_index(docs, index_name, schema), do: bulk_index(docs, index_name, index_name, schema, false)

  def bulk_index(docs, index_name, type_name, schema, opts \\ [], update? \\ false)

  def bulk_index(docs, index_name, type_name, schema, [with_enum: true], update?) when is_list(docs) do
    bulk =
      docs
      |> Enum.flat_map(fn doc ->
        case update? do
          true  -> [%{update: %{_id: doc.id, _type: index_name, _index: index_name}}, %{doc: schema.to_doc(doc)}]
          _     -> [%{index: %{_id: doc.id}}, %{doc: schema.to_doc(doc)}]
        end
      end)
      |> Enum.reduce("", fn line, payload ->
        payload <> Jason.encode!(line) <> "\n"
      end)

    API.post("/#{index_name}/#{type_name}/_bulk", bulk)
  end

  def bulk_index(docs, index_name, type_name, schema, _opts, update?) when is_list(docs) do
    docs
    |> Flow.from_enumerable()
    |> bulk_index(index_name, type_name, schema, update?)
  end

  def bulk_index(flow, index_name, type_name, schema, _opts, update?) do
    flow
    |> Flow.map(fn doc ->
      case update? do
        true  -> [%{update: %{_id: doc.id, _type: index_name, _index: index_name}}, %{doc: schema.to_doc(doc)}]
        _     -> [%{index: %{_id: doc.id}}, schema.to_doc(doc)]
      end
    end)
    |> batch(Flex.config(:batch_size, "250") |> String.to_integer())
    |> Flow.map_state(fn lines ->
      Enum.reduce(lines, "", fn line, payload ->
        payload <> Jason.encode!(line) <> "\n"
      end)
    end)
    |> Flow.each_state(fn
      "" ->
        true

      bulk ->
        API.post("/#{index_name}/#{type_name}/_bulk", bulk)
    end)
    |> Flow.run()
  end

  def batch(flow, count) do
    flow
    |> Flow.partition(
      window: Flow.Window.count(count),
      stages:
        Flex.config(
          :concurrency,
          :erlang.system_info(:logical_processors_available) |> Integer.to_string()
        )
        |> String.to_integer()
    )
    |> Flow.reduce(fn -> [] end, fn line, lines -> line ++ lines end)
  end

  defp index_config(name) do
    {postfix_with_timestamp(name), %{aliases: %{name => %{}}}}
  end

  defp postfix_with_timestamp(name) do
    DateTime.utc_now()
    |> DateTime.to_unix(:microsecond)
    |> to_string()
    |> List.wrap()
    |> List.insert_at(0, name)
    |> Enum.join("_")
  end

  defp maybe_add_aliases(options, aliases, with_alias) do
    case with_alias do
      true -> Map.merge(options, aliases)
      false -> options
    end
  end
end
