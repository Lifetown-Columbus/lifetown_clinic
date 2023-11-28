defmodule LifetownClinic.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      timestamps()
    end
  end
end
