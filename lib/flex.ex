defmodule Flex do
  @moduledoc """
  Documentation for Flex.
  """

  @doc false
  def config, do: Application.get_all_env(:flex)
  @doc false
  def config(key, default \\ nil), do: Application.get_env(:flex, key, default)
end
