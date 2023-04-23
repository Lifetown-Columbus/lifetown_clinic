defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.Reception
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.Student
  alias LifetownClinicWeb.Confirmation

  @pubsub LifetownClinic.PubSub

  def mount(_, _, socket) do
    PubSub.subscribe(@pubsub, "front_desk")

    socket =
      socket
      |> assign(:confirming, nil)
      |> fetch_all()

    {:ok, socket}
  end

  def handle_info(:student_checked_in, socket) do
    {:noreply, assign(socket, :checked_in, Reception.all())}
  end

  def handle_info(:student_removed, socket) do
    {:noreply, fetch_all(socket)}
  end

  def handle_event("confirm", %{"name" => name}, socket) do
    {:noreply, assign(socket, :confirming, Confirmation.new(name))}
  end

  def handle_event("save", %{"name" => name, "school" => school}, socket) do
    Reception.confirm(name, school)

    socket =
      socket
      |> assign(:confirming, nil)
      |> fetch_all()

    {:noreply, socket}
  end

  def handle_event("lookup-school", %{"school" => school}, socket) do
    confirmation = Confirmation.lookup_school(socket.assigns.confirming, school)

    {:noreply, assign(socket, :confirming, confirmation)}
  end

  defp fetch_all(socket) do
    confirmed_today =
      Student.checked_in_today()
      |> Repo.all()
      |> Repo.preload(:school)

    socket
    |> assign(:checked_in, Reception.all())
    |> assign(:confirmed, confirmed_today)
  end
end
