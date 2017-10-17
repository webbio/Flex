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
  defp fetch(data, field)        when is_atom(field), do: fetch(data, field, field in Map.keys(data))    
  defp fetch(data, {key, field}) when is_atom(field), do: fetch(data, {key, field}, field in Map.keys(data))    
  defp fetch(_, {key, field}),                        do: {key, field}
  defp fetch(data, field, true)  when is_atom(field), do: {field, Map.get(data, field)}    
  defp fetch(data, field, false) when is_atom(field), do: {field, apply(data.__struct__, field, [data])}    
  defp fetch(data, {key, field}, true),               do: {key, Map.get(data, field)}    
  defp fetch(data, {key, field}, false),              do: {key, apply(data.__struct__, field, [data])}    
end