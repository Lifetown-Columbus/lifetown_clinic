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

    socket =
      socket
      |> assign(:school, school)
      |> assign(:students, students)

    {:ok, socket}
  end
end
