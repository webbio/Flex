defmodule Flex.HTTP do
  use HTTPoison.Base

  def process_url(url) do
    "http://elasticsearch:9200" <> url
  end

  def process_response_body(""), do: ""
  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def process_request_body(body) when is_map(body) or is_list(body) do
    body
    |> Poison.encode!
  end
  def process_request_body(body), do: body

  def process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end
  def process_request_headers(headers) do
    [{"Content-Type", "application/json; charset=UTF-8"} | headers]
  end
end