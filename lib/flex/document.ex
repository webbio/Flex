defmodule Flex.Document do
  alias Flex.API
  
  def create(doc), do: create(doc, doc.__struct__)
  def create(doc, schema), do: create(doc, schema, schema.flex_name())
  def create(doc, schema, index_name) do
    [index_name, index_name, doc.id, "_create?refresh"] |> make_path |> API.put(schema.to_doc(doc))
  end
  
  def update(doc), do: update(doc, doc.__struct__)
  def update(doc, schema), do: update(doc, schema, schema.flex_name())
  def update(doc, schema, index_name) do
    [index_name, index_name, "#{doc.id}?refresh"] |> make_path |> API.put(schema.to_doc(doc))
  end
  
  def delete(doc), do: delete(doc, doc.__struct__)
  def delete(doc, schema), do: delete(doc, schema, schema.flex_name())
  def delete(doc, schema, index_name) do
    [index_name, index_name, "#{doc.id}?refresh"] |> make_path |> API.delete
  end
  
  def get(index_name, id) do
    [index_name, index_name, id] |> make_path |> API.get
  end
  
  @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end