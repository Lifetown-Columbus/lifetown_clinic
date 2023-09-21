defmodule LifetownClinic.Students do
  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def save_student(params, student) do
    student
    |> Student.changeset(params)
    |> Repo.insert_or_update(force: true)
  end

  def lookup_school(query) do
    query
    |> School.starts_with()
    |> Repo.all()
  end
end
