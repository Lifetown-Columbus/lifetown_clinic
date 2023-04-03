defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.{FrontDesk, School, Student, Repo}

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
    {:noreply, assign(socket, :checked_in, FrontDesk.all())}
  end

  def handle_info(:student_removed, socket) do
    {:noreply, fetch_all(socket)}
  end

  def handle_event("confirm", %{"name" => name}, socket) do
    {:noreply, assign(socket, :confirming, %Student{name: name})}
  end

  def handle_event("save", %{"name" => name, "school" => school}, socket) do
    FrontDesk.remove(name)

    %Student{school: %School{name: school}}
    |> Student.changeset(%{name: name})
    |> Repo.insert!()

    socket =
      socket
      |> assign(:confirming, nil)
      |> fetch_all()

    {:noreply, socket}
  end

  defp fetch_all(socket) do
    confirmed_today =
      Student.checked_in_today()
      |> Repo.all()
      |> Repo.preload(:school)

    socket
    |> assign(:checked_in, FrontDesk.all())
    |> assign(:confirmed, confirmed_today)
  end
end
