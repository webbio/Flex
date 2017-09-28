defmodule Elastic.IndexTest do
  use ExUnit.Case
  alias Elastic.Index
  doctest Index

  setup do
    Index.delete "elastic_test_index"
    on_exit fn -> Index.delete "elastic_test_index" end
    :ok
  end
end
