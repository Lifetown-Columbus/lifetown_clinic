defmodule LifetownClinicWeb.SchoolLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Repo

  def mount(%{"id" => id}, _, socket) do
    school =
      School
      |> Repo.get(id)
      |> Repo.preload(students: [:lessons])

    socket =
      socket
      |> assign(:school, school)
      |> assign(:form, nil)
      |> assign(:deleting, false)
      |> assign(:students, school.students)

    {:ok, socket}
  end

  def lessons_string(lessons) do
    lessons
    |> Enum.map(fn l -> l.number end)
    |> Enum.join(",")
  end

  def handle_event("edit", _, socket) do
    form =
      socket.assigns.school
      |> School.changeset(%{})
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("delete", _, socket) do
    {:noreply, assign(socket, :deleting, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :deleting, false)}
  end

  def handle_event("confirm_delete", _, socket) do
    Repo.delete!(socket.assigns.school)
    {:noreply, push_navigate(socket, to: "/admin/schools", replace: true)}
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
