defmodule LifetownClinic.Repo.Migrations.StudentBelongsToSchool do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add(:school_id, references(:schools))
    end
  end
end
