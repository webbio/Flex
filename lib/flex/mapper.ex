defprotocol Flex.Mapper do
  def to_doc(data)
end

defmodule Flex.Mapper.Struct do
  def to_doc(struct, fields) do
    for field <- fields, into: %{} do
      struct |> fetch(field)
    end
  end
  
  defp fetch(struct, field) when is_atom(field) do
    if field in Map.keys(struct) do
      {field, Map.get(struct, field)}
    else
      {field, apply(__MODULE__, field, [struct])}
    end
  end
  defp fetch(struct, {key, field}) do
    if field in Map.keys(struct) do
      {key, Map.get(struct, field)}
    else
      {key, apply(__MODULE__, field, [struct])}
    end
  end
end