defmodule LifetownClinic.Repo.Migrations.AddNumberToLessons do
  use Ecto.Migration

  def change do
    alter table("lessons") do
      add :number, :integer
    end
  end
end
