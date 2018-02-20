defmodule Flex.API do
  @moduledoc """
  This module provides a small wrapper around the Flex HTTP responses
  """

  alias Flex.HTTP
  require Logger

  def get(path), do: unwrap(:get, path)
  def head(path), do: unwrap(:head, path)
  def post(path), do: unwrap(:post, path)
  def post(path, data), do: unwrap(:post, path, data)
  def put(path), do: unwrap(:put, path)
  def put(path, data), do: unwrap(:put, path, data)
  def patch(path), do: unwrap(:patch, path)
  def patch(path, data), do: unwrap(:patch, path, data)
  def delete(path), do: unwrap(:delete, path)
  def delete(path, data), do: unwrap(:delete, path, data)

  @doc false
  defp unwrap(action, path, data \\ %{}, headers \\ []) do
    headers = add_basic_authentication(headers)

    with {:ok, %{body: body, status_code: 200}} <-
           HTTP.request(
             action,
             path,
             data,
             headers,
             timeout: 100_000,
             recv_timeout: 100_000
           ) do
      {:ok, body}
    else
      {:ok, %{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %{body: %{"error" => %{"type" => error_type}}} = err} ->
        Logger.warn("Elastic error: #{inspect(err)}")
        {:error, String.to_atom(error_type)}

      err ->
        err
    end
  end

  defp add_basic_authentication(headers) do
    cond do
      headers |> Enum.map(fn {key, _} -> key end) |> Enum.member?("Authorization") ->
        headers

      Flex.config(:elastic_username) && Flex.config(:elastic_password) ->
        encoded_credentials =
          Base.encode64("#{Flex.config(:elastic_username)}:#{Flex.config(:elastic_password)}")

        [{"authorization", "basic #{encoded_credentials}"}] ++ headers

      true ->
        headers
    end
  end
end