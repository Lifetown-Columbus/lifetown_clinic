defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.FrontDesk

  @pubsub LifetownClinic.PubSub

  def mount(_, _, socket) do
    PubSub.subscribe(@pubsub, "front_desk")

    socket =
      socket
      |> assign(:checked_in, FrontDesk.all())
      |> assign(:confirmed, [])

    {:ok, socket}
  end

  def handle_info(:student_checked_in, socket) do
    {:noreply, assign(socket, :checked_in, FrontDesk.all())}
  end

  def handle_event("confirm", %{"name" => name}, socket) do
    {:noreply, socket}
  end
end
