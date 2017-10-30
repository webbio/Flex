defmodule Flex.Factory do
  @moduledoc """
  This module contains factory functions useful for testing
  """

  use ExMachina.Ecto, repo: Flex.Dummy.Repo
  alias Flex.Dummy.Book

  @doc false
  def book_factory do
    %Book{
      name: sequence("Book"),
      release_year: sequence(:release_year, fn (_) -> 2000..2017 |> Enum.random end),
    }
  end
end
