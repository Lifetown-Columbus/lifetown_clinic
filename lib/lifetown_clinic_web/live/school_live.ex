defmodule LifetownClinicWeb.SchoolLive do
  alias LifetownClinic.Students
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def mount(%{"id" => id}, _, socket) do
    {:ok, fetch_all(socket, id)}
  end

  def fetch_all(socket, id) do
    school =
      School
      |> Repo.get(id)
      |> Repo.preload(students: [:lessons])

    progress =
      Enum.reduce(0..6, %{}, fn i, acc -> Map.put(acc, i, students_by_progress(school.id, i)) end)

    socket
    |> assign(:school, school)
    |> assign(:form, nil)
    |> assign(:deleting, false)
    |> assign(:students, school.students)
    |> assign(:students_by_progress, progress)
    |> assign(:selected_student, nil)
    |> assign(:deleting_student, nil)
  end

  defp students_by_progress(school_id, lesson_number) do
    Student.by_lesson_number(school_id, lesson_number)
    |> Repo.all()
  end

  def lessons_string(lessons) do
    lessons
    |> Enum.map(fn l -> l.number end)
    |> Enum.join(",")
  end

  def handle_event("edit", _, socket) do
    form =
      socket.assigns.school
      |> School.changeset(%{})
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("delete", _, socket) do
    {:noreply, assign(socket, :deleting, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, :deleting, false)}
  end

  def handle_event("confirm_delete", _, socket) do
    Repo.delete!(socket.assigns.school)
    {:noreply, push_navigate(socket, to: "/admin/schools", replace: true)}
  end

  def handle_event("validate", %{"school" => params}, socket) do
    form =
      socket.assigns.school
      |> School.changeset(params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"school" => params}, socket) do
    school =
      socket.assigns.school
      |> School.changeset(params)
      |> Repo.update!()

    socket =
      socket
      |> assign(:form, nil)
      |> assign(:school, school)

    {:noreply, socket}
  end

  def handle_event("delete_student", %{"id" => id}, socket) do
    student = Repo.get!(Student, id)
    {:noreply, assign(socket, :deleting_student, student)}
  end

  def handle_event("confirm_delete_student", _, socket) do
    Repo.delete!(socket.assigns.deleting_student)
    {:noreply, fetch_all(socket, socket.assigns.school.id)}
  end

  def handle_event("cancel_delete_student", _, socket) do
    {:noreply, assign(socket, :deleting_student, nil)}
  end

  def handle_event("select_student", %{"id" => id}, socket) do
    student = Students.get_with_lessons(id)
    {:noreply, assign(socket, :selected_student, student)}
  end

  def handle_event("cancel_student_selection", _, socket) do
    {:noreply, assign(socket, :selected_student, nil)}
  end

  def handle_info(:student_confirmed, socket) do
    {:noreply, fetch_all(socket, socket.assigns.school.id)}
  end
end
