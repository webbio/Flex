defmodule Flex.Store do
  alias Flex.Document
  
  defmacro __using__(opts) do
    quote do
      @repo unquote(opts[:repo])
      
      import Flex.Store
      
      def insert(changeset), do: insert(changeset, @repo)
    end
  end
  
  def insert(changeset, repo) do
    repo.transaction(fn ->
      with {:ok, doc} <- changeset |> repo.insert(),
           {:ok, _} <- Document.create(doc)
      do
        doc
      else
        {:error, err} -> repo.rollback(err)
        _ -> repo.rollback(:unknown_error)
      end
    end)
  end
end