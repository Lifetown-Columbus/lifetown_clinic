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
      |> assign(:form, nil)
      |> assign(:student_count, Enum.count(school.students))
      |> assign(:students_by_progress, students_by_progress)

    {:ok, socket}
  end

  def handle_event("edit", _, socket) do
    form =
      socket.assigns.school
      |> School.changeset(%{})
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("validate", %{"school" => params}, socket) do
    form =
      socket.assigns.school
      |> School.changeset(params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"school" => params}, socket) do
    school =
      socket.assigns.school
      |> School.changeset(params)
      |> Repo.update!()

    socket =
      socket
      |> assign(:form, nil)
      |> assign(:school, school)

    {:noreply, socket}
  end
end
