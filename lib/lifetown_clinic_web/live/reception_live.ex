defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.{FrontDesk, School, Student, Repo}
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
    {:noreply, assign(socket, :checked_in, FrontDesk.all())}
  end

  def handle_info(:student_removed, socket) do
    {:noreply, fetch_all(socket)}
  end

  def handle_event("confirm", %{"name" => name}, socket) do
    {:noreply, assign(socket, :confirming, Confirmation.new_student(name))}
  end

  def handle_event("save", %{"name" => name, "school" => school}, socket) do
    FrontDesk.remove(name)

    %Student{}
    |> maybe_find_school(school)
    |> Student.changeset(%{name: name})
    |> Repo.insert!()

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
    |> assign(:checked_in, FrontDesk.all())
    |> assign(:confirmed, confirmed_today)
  end

  defp maybe_find_school(student, school_name) do
    case Repo.get_by(School, name: school_name) do
      nil ->
        Map.put(student, :school, %School{name: school_name})

      school ->
        Map.put(student, :school, school)
    end
  end
end
