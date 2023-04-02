defmodule LifetownClinic.Repo.Migrations.CreateSchools do
  use Ecto.Migration

  def change do
    create table(:schools) do
      add :name, :string

      timestamps()
    end

    create unique_index(:schools, [:name])
  end
end
