defmodule LifetownClinicWeb.SchoolLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def mount(%{"id" => id}, _, socket) do
    school =
      School
      |> Repo.get(id)

    students =
      id
      |> Student.by_school()
      |> Repo.all()
      |> Repo.preload(:lessons)
      |> Enum.group_by(fn st -> Enum.count(st.lessons) end)

    socket =
      socket
      |> assign(:school, school)
      |> assign(:students_by_progress, students)

    {:ok, socket}
  end
end
