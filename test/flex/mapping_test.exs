defmodule Flex.MappingTest do
  use ExUnit.Case
  alias Flex.{Index, Mapping}
  doctest Mapping

  setup do
    Index.create "elastic_test_index"
    on_exit fn -> Index.delete "elastic_test_index" end
    :ok
  end
end
