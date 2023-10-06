defmodule LifetownClinicWeb.StudentLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def mount(%{"id" => id}, _, socket) do
    student =
      Student
      |> Repo.get(id)
      |> Repo.preload([:school, :lessons])

    socket =
      socket
      |> assign(:student, student)
      |> assign(:deleting, false)

    {:ok, socket}
  end

  def handle_event("delete", _, socket) do
    {:noreply, assign(socket, :deleting, true)}
  end

  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :deleting, false)}
  end

  def handle_event("confirm_delete", _, socket) do
    Repo.delete!(socket.assigns.student)
    {:noreply, push_navigate(socket, to: "/admin", replace: true)}
  end
end
