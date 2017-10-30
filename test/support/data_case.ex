defmodule Flex.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Flex.Index

  using do
    quote do
      alias Flex.Dummy.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Flex.Factory
    end
  end

  setup tags do
    Index.delete_all()
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Flex.Dummy.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Flex.Dummy.Repo, {:shared, self()})
    end
    
    # on_exit &Index.delete_all/0

    :ok
  end
end
