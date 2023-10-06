defmodule LifetownClinicWeb.SchoolLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def mount(%{"id" => id}, _, socket) do
    school =
      School
      |> Repo.get(id)
      |> Repo.preload(:students)

    students_by_progress =
      id
      |> Student.by_school()
      |> Repo.all()
      |> Repo.preload(:lessons)
      |> Enum.group_by(fn st -> Enum.count(st.lessons) end)

    socket =
      socket
      |> assign(:school, school)
      |> assign(:student_count, Enum.count(school.students))
      |> assign(:students_by_progress, students_by_progress)

    {:ok, socket}
  end
end
