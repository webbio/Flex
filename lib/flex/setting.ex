defmodule Flex.Setting do
  @moduledoc """
  This module provides an interface for working with settings
  """
  alias Flex.API

  @doc """
  Put settings

  ## Examples

     iex> settings = %{
     ...>   index: %{
     ...>     number_of_replicas: 2
     ...>   }
     ...> }
     ...> Flex.Setting.put "elastic_test_index", settings
     {:ok, %{"acknowledged" => true}}
     iex> more_settings = %{
     ...>   index: %{
     ...>     refresh_interval: -1
     ...>   }
     ...> }
     ...> Flex.Setting.put "elastic_test_index", more_settings
     ...> match?(
     ...>   {:ok, %{"index" => %{ "number_of_replicas" => "2", "refresh_interval" => "-1" } } },
     ...>   Flex.Setting.get "elastic_test_index"
     ...> )
     true
  """
  def put(index, %{} = settings) do
    [index, :_settings] |> make_path |> API.put(settings)
  end

  @doc """
  Get settings

  ## Examples

     iex> settings = %{
     ...>   index: %{
     ...>     number_of_replicas: 2
     ...>   }
     ...> }
     ...> Flex.Setting.put "elastic_test_index", settings
     ...> match?(
     ...>   {:ok, %{"index" => %{"number_of_replicas" => "2" } } },
     ...>   Flex.Setting.get "elastic_test_index"
     ...> )
     true
  """
  def get(index) do
    with {:ok, %{^index => %{"settings" => settings}}} <- [index, :_settings] |> make_path |> API.get
    do
      {:ok, settings}
    else
      err -> err
    end
  end

 @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end