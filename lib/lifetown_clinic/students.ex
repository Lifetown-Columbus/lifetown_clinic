defmodule LifetownClinic.Students do
  alias LifetownClinic.Schema.School
  alias LifetownClinic.Repo

  def save_student(changeset) do
    Repo.insert_or_update(changeset, force: true)
  end

  def lookup_school(query) do
    query
    |> School.starts_with()
    |> Repo.all()
  end
end
