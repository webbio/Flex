defmodule Flex.Mapper.StructTest do
  use ExUnit.Case
  alias Flex.Mapper.Struct
  
  defmodule Book, do: defstruct [:name, :author]
  doctest Struct
end