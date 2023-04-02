defmodule LifetownClinic.Repo.Migrations.StudentHasManyLessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add(:student_id, references(:students))
    end
  end
end
