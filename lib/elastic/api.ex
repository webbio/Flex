defmodule Elastic.API do
  @moduledoc """
  This module provides a small wrapper around the Elastic HTTP responses
  """

  alias Elastic.HTTP

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
  defp unwrap(action, path, data \\ %{}) do
    with {:ok, %{body: body, status_code: 200}} <- apply(Elastic.HTTP, action, [path, data])
    do
      {:ok, body}
    else
      {:ok, %{body: %{"error" => %{"type" => error_type}}}} -> {:error, String.to_atom(error_type)}
      {:ok, %{status_code: 404}} -> {:error, :not_found}
      err -> err
    end
  end
end
