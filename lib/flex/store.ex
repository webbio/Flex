defmodule Flex.Store do
  alias Flex.Document
  
  defmacro __using__(opts) do
    quote do
      @repo unquote(opts[:repo])
      
      import Flex.Store
      
      def insert(changeset), do: insert(changeset, @repo)
      def update(changeset), do: update(changeset, @repo)
      def delete(changeset), do: delete(changeset, @repo)
    end
  end
  
  def insert(struct_or_changeset, repo) do
    repo.transaction(fn ->
      with {:ok, doc} <- struct_or_changeset |> repo.insert(),
           {:ok, _} <- Document.create(doc)
      do
        doc
      else
        {:error, err} -> repo.rollback(err)
        _ -> repo.rollback(:unknown_error)
      end
    end)
  end
  
  def update(changeset, repo) do
    repo.transaction(fn ->
      with {:ok, doc} <- changeset |> repo.update(),
           {:ok, _} <- Document.update(doc)
      do
        doc
      else
        {:error, err} -> repo.rollback(err)
        _ -> repo.rollback(:unknown_error)
      end
    end)
  end
  
  def delete(struct_or_changeset, repo) do
    repo.transaction(fn ->
      with {:ok, doc} <- struct_or_changeset |> repo.delete(),
           {:ok, _} <- Document.delete(doc)
      do
        doc
      else
        {:error, err} -> repo.rollback(err)
        _ -> repo.rollback(:unknown_error)
      end
    end)
  end
end