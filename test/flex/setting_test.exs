defmodule Flex.SettingTest do
  use ExUnit.Case
  alias Flex.{Index, Setting}
  doctest Setting

  setup do
    Index.create "elastic_test_index"
    on_exit fn -> Index.delete "elastic_test_index" end
    :ok
  end
end
