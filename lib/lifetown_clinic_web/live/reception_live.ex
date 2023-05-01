defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.Reception
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.{School, Student}
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

  def handle_event("select_student", %{"id" => "new"}, socket) do
    {:noreply, update(socket, :confirming, fn c -> Confirmation.select_student(c, nil) end)}
  end

  def handle_event("save", %{"name" => name, "school" => school}, socket) do
    with {:ok, _} <- save_student(name, school) do
      Reception.confirm(name)

      socket =
        socket
        |> assign(:confirming, nil)
        |> fetch_all()

      {:noreply, socket}
    else
      {:error, changeset} ->
        IO.inspect(changeset)

        {:noreply, socket}
    end
  end

  def handle_event("lookup-school", %{"school" => school}, socket) do
    confirmation = Confirmation.lookup_school(socket.assigns.confirming, school)

    {:noreply, assign(socket, :confirming, confirmation)}
  end

  defp save_student(name, school) do
    %Student{}
    |> maybe_find_school(school)
    |> Student.changeset(%{name: name})
    |> Repo.insert()
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

  defp maybe_find_school(student, school_name) do
    case Repo.get_by(School, name: school_name) do
      nil ->
        Map.put(student, :school, %School{name: school_name})

      school ->
        Map.put(student, :school, school)
    end
  end
end
