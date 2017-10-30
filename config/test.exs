use Mix.Config

config :flex,
  elastic_url: "http://127.0.0.1:9200",
  test_index: "elastic_test_index"

config :flex, Flex.Dummy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "tienkb",
  database: "flex_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

config :flex, :ecto_repos, [Flex.Dummy.Repo]
