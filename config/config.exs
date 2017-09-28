# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elastic,
  elastic_url: "http://127.0.0.1:9200",
  test_index: "elastic_test_index"