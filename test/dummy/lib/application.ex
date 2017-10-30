defmodule Flex.Dummy.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Flex.Dummy.Repo, []),
    ], strategy: :one_for_one, name: Flex.Dummy.Supervisor)
  end
end
