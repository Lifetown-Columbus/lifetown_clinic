defmodule LifetownClinic.Students do
  alias LifetownClinic.Schema.{School, Student}
  alias LifetownClinic.Repo

  def save_student(student, params) do
    student
    |> Student.changeset(params)
    |> Repo.insert_or_update(force: true)
  end

  def lookup_school(query) do
    query
    |> School.search()
    |> Repo.all()
  end
end
