defmodule Flex.IndexTest do
  use ExUnit.Case
  alias Flex.Index
  doctest Index

  setup do
    on_exit fn -> Index.delete "elastic_test_index" end
    :ok
  end
end
