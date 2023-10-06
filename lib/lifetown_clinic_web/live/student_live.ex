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

    {:ok, socket}
  end
end
