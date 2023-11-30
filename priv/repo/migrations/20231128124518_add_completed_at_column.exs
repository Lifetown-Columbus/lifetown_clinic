defmodule LifetownClinic.Repo.Migrations.AddCompletedAtColumn do
  use Ecto.Migration

  def change do
    alter table("lessons") do
      add(:completed_at, :date)
    end

    execute("UPDATE lessons SET completed_at = inserted_at::date")

    create(index("lessons", [:completed_at]))
  end
end
