defmodule LifetownClinic.Students do
  import Ecto.Query
  alias LifetownClinic.Schema.{School, Student, Lesson}
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

  def checked_in_today() do
    Student.checked_in_today()
    |> Repo.all()
    |> Repo.preload(:school)
    |> Repo.preload(lessons: from(l in Lesson, order_by: [asc: l.completed_at]))
  end

  def get_with_lessons(id) do
    Student
    |> Repo.get!(id)
    |> Repo.preload(:school)
    |> Repo.preload(lessons: from(l in Lesson, order_by: [asc: l.completed_at]))
  end

  def by_name_with_lessons(name) do
    name
    |> Student.by_name()
    |> Repo.all()
    |> Repo.preload(:school)
    |> Repo.preload(lessons: from(l in Lesson, order_by: [asc: l.completed_at]))
  end
end
