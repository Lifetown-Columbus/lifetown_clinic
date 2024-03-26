defmodule LifetownClinic.Repo.Migrations.IncrementLessonNumbers do
  use Ecto.Migration
  import Ecto.Query

  alias LifetownClinic.Schema.{Lesson, Student}
  alias LifetownClinic.Repo

  def change do
    Student
    |> Repo.all()
    |> Repo.preload(lessons: from(l in Lesson, order_by: [asc: l.completed_at]))
    |> Enum.each(&increment_lessons/1)
  end

  defp increment_lessons(student) do
    lessons =
      student.lessons
      |> Enum.take(6)
      |> Stream.with_index()
      |> Enum.map(&increment_lesson_number/1)
      |> Enum.map(&Repo.update/1)
  end

  defp increment_lesson_number({lesson, index}) do
    Lesson.changeset(lesson, %{number: index + 1})
  end
end
