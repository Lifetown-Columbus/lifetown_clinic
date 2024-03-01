defmodule LifetownClinic.Repo.Migrations.AddNumberToLessons do
  use Ecto.Migration

  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.Lesson

  def change do
    alter table("lessons") do
      add :number, :integer, default: 1
    end
  end
end
