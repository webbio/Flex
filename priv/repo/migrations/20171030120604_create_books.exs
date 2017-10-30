defmodule Flex.Dummy.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :release_year, :integer
      
      timestamps()
    end
  end
end
