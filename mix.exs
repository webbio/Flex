defmodule Flex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :flex,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: mod(Mix.env)
    ]
  end
  
  defp elixirc_paths(:test), do: ["lib", "test/dummy", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
  
  defp mod(:test), do: {Flex.Dummy.Application, []}
  defp mod(_), do: []

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:plug, "~> 1.4.3"},
      {:flow, "~> 0.11"},
      {:ecto, "~> 2.2.4"},
      {:jason, "~> 1.0.0-rc.1"},
      {:phoenix, "~> 1.3.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.1", only: :test},
      {:postgrex, "~> 0.13.0", only: :test},
    ]
  end
end
