defmodule LifetownClinic.Students do
  import Ecto.Query
  alias LifetownClinic.Schema.{Student, Lesson}
  alias LifetownClinic.Repo

  def save_student(student, params) do
    student
    |> Student.changeset(params)
    # force true so timestamps are updated
    |> Repo.insert_or_update(force: true)
  end

  def checked_in_today() do
    Student.checked_in_today()
    |> Repo.all()
    |> with_associations()
  end

  def get(id) do
    Student
    |> Repo.get!(id)
    |> with_associations()
  end

  def by_name_with_lessons(name) do
    name
    |> Student.by_name()
    |> Repo.all()
    |> with_associations()
  end

  def search(query) do
    query
    |> Student.search()
    |> Repo.all()
    |> with_associations()
  end

  def add_lesson(changeset), do: Student.add_lesson(changeset)
  def remove_lesson(changeset, index), do: Student.remove_lesson(changeset, index)

  defp with_associations(students) do
    students
    |> Repo.preload(:school)
    |> Repo.preload(lessons: from(l in Lesson, order_by: [asc: l.completed_at]))
  end
end
