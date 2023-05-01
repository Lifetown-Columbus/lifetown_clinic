defmodule LifetownClinic.Repo.Migrations.AddUniqueIndexToStudents do
  use Ecto.Migration

  def change do
    create(unique_index(:students, [:name, :school_id]))
  end
end
