defmodule Elastic do
  @moduledoc """
  Documentation for Elastic.
  """

  @doc false
  def config, do: Application.get_all_env(:elastic)
  @doc false
  def config(key, default \\ nil), do: Application.get_env(:elastic, key, default)
end
