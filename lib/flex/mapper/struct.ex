defmodule Flex.Mapper.Struct do
  @moduledoc """
  This module defines a configurable to_doc/1 implementation for Structs
  """
  
  @doc """
  Transforms a struct into a map defined by a fields list
    
  ## Example
  
    iex> book = %Book{name: "Programming Elixir 1.3", author: "Dave Thomas"}
    ...> Flex.Mapper.Struct.to_doc(book, [:name, writer: :author, foo: "foo"])
    %{name: "Programming Elixir 1.3", writer: "Dave Thomas", foo: "foo"}
  """
  def to_doc(data, fields) do
    for field <- fields, into: %{} do
      data |> fetch(field)
    end
  end
  
  @doc false
  defp fetch(data, field) when is_atom(field) do
    if field in Map.keys(data) do
      {field, Map.get(data, field)}
    else
      {field, apply(data.__struct__, field, [data])}
    end
  end
  defp fetch(data, {key, field}) when is_atom(field) do
    if field in Map.keys(data) do
      {key, Map.get(data, field)}
    else
      {key, apply(data.__struct__, field, [data])}
    end
  end
  defp fetch(data, {key, field}), do: {key, field}
end