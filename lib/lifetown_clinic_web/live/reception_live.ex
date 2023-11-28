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

  def handle_info(:student_confirmed, socket) do
    Reception.confirm(socket.assigns.confirming.id)

    socket =
      socket
      |> assign(:confirming, nil)
      |> fetch_all()

    {:noreply, socket}
  end

  def handle_event("confirm", %{"id" => id, "name" => name}, socket) do
    {:noreply, assign(socket, :confirming, Confirmation.new(id, name))}
  end

  def handle_event("remove", %{"id" => id}, socket) do
    Reception.remove(id)
    {:noreply, assign(socket, :confirming, nil)}
  end

  def handle_event("cancel_confirmation", _, socket) do
    {:noreply, assign(socket, :confirming, nil) |> fetch_all()}
  end

  def handle_event("update_name", %{"name" => name}, socket) do
    {:noreply, update(socket, :confirming, fn c -> Confirmation.update_name(c, name) end)}
  end

  def handle_event("select_student", %{"id" => "new"}, socket) do
    {:noreply, update(socket, :confirming, fn c -> Confirmation.select_student(c, nil) end)}
  end

  def handle_event("select_student", %{"id" => id}, socket) do
    confirmation = socket.assigns.confirming

    if is_nil(confirmation) do
      socket =
        assign(
          socket,
          :confirming,
          Confirmation.select_student(Confirmation.new(id, ""), id)
        )

      {:noreply, socket}
    else
      {:noreply, update(socket, :confirming, fn c -> Confirmation.select_student(c, id) end)}
    end
  end

  defp fetch_all(socket) do
    confirmed_today =
      Student.checked_in_today()
      |> Repo.all()
      |> Repo.preload(:school)
      |> Repo.preload(:lessons)

    socket
    |> assign(:checked_in, Reception.all())
    |> assign(:confirmed, confirmed_today)
  end
end
