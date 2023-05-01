defmodule LifetownClinicWeb.ReceptionLive do
  use LifetownClinicWeb, :live_view

  alias Phoenix.PubSub
  alias LifetownClinic.Reception
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.{Lesson, School, Student}
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

  def handle_event("cancel_confirmation", _, socket) do
    {:noreply, assign(socket, :confirming, nil)}
  end

  def handle_event("select_student", %{"id" => "new"}, socket) do
    {:noreply, update(socket, :confirming, fn c -> Confirmation.select_student(c, nil) end)}
  end

  def handle_event("select_student", %{"id" => id}, socket) do
    {:noreply, update(socket, :confirming, fn c -> Confirmation.select_student(c, id) end)}
  end

  def handle_event("save", %{"school" => school}, socket) do
    with confirmation <- socket.assigns.confirming,
         {:ok, _} <- save_student(confirmation, school) do
      Reception.confirm(confirmation.name)

      socket =
        socket
        |> assign(:confirming, nil)
        |> fetch_all()

      {:noreply, socket}
    else
      {:error, changeset} ->
        IO.inspect(changeset, label: "TODO")
        {:noreply, socket}
    end
  end

  def handle_event("lookup-school", %{"school" => school}, socket) do
    confirmation = Confirmation.lookup_school(socket.assigns.confirming, school)

    {:noreply, assign(socket, :confirming, confirmation)}
  end

  def handle_event("add_lesson", _, socket) do
    student = socket.assigns.confirming.student

    if Enum.count(student.lessons) < 6 do
      student
      |> Ecto.build_assoc(:lessons)
      |> Lesson.changeset(%{})
      |> Repo.insert()
    end

    {:noreply,
     update(socket, :confirming, fn c -> Confirmation.select_student(c, student.id) end)}
  end

  def handle_event("remove_lesson", _, socket) do
    student = socket.assigns.confirming.student

    if Enum.count(student.lessons) > 0 do
      student.lessons
      |> List.last()
      |> Repo.delete()
    end

    {:noreply,
     update(socket, :confirming, fn c -> Confirmation.select_student(c, student.id) end)}
  end

  defp save_student(confirmation, school) do
    confirmation.student
    |> Student.changeset(%{name: confirmation.name})
    |> maybe_find_school(school)
    # force updated_at to change to now
    |> Repo.insert_or_update(force: true)
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

  defp maybe_find_school(changeset, school_name) do
    case Repo.get_by(School, name: school_name) do
      nil ->
        Student.changeset(changeset, %{school: %{name: school_name}})

      school ->
        Ecto.Changeset.put_assoc(changeset, :school, school)
    end
  end
end
