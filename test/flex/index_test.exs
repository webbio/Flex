defmodule Flex.IndexTest do
  use ExUnit.Case
  alias Flex.Index
  doctest Index

  setup do
    Index.delete "elastic_test_index"
    on_exit fn -> Index.delete "elastic_test_index" end
    :ok
  end
end
