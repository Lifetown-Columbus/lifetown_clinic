defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.{FrontDesk, Repo, Student}

  @pubsub LifetownClinic.PubSub

  def mount(_, _, socket) do
    PubSub.subscribe(@pubsub, "front_desk")

    {:ok, fetch_all(socket)}
  end

  def handle_info(:student_checked_in, socket) do
    {:noreply, assign(socket, :checked_in, FrontDesk.all())}
  end

  def handle_event("confirm", %{"name" => name}, socket) do
    FrontDesk.confirm(name)
    {:noreply, fetch_all(socket)}
  end

  defp fetch_all(socket) do
    confirmed_today =
      Student.checked_in_today()
      |> Repo.all()

    socket
    |> assign(:checked_in, FrontDesk.all())
    |> assign(:confirmed, confirmed_today)
  end
end
