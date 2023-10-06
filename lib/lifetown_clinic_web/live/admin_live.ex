defmodule LifetownClinicWeb.AdminLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Reporting
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:start_date, nil)
      |> assign(:end_date, nil)
      |> assign(:schools, [])
      |> assign(:students, [])
      |> fetch_results()

    {:ok, socket}
  end

  def handle_event(
        "filter_updated",
        %{"start-date" => start_date, "end-date" => end_date},
        socket
      ) do
    socket =
      socket
      |> assign(:start_date, start_date)
      |> assign(:end_date, end_date)
      |> fetch_results()

    {:noreply, socket}
  end

  def handle_event("add-school", %{"school-name" => school_name}, socket) do
    %School{}
    |> School.changeset(%{"name" => school_name})
    |> Repo.insert()

    socket =
      socket
      |> fetch_results()

    {:noreply, socket}
  end

  def handle_event("find-school", %{"query" => query}, socket) do
    schools =
      query
      |> School.search()
      |> Repo.all()
      |> Repo.preload(:students)

    {:noreply, assign(socket, :schools, schools)}
  end

  def handle_event("find-student", %{"query" => query}, socket) do
    students =
      query
      |> Student.search()
      |> Repo.all()
      |> Repo.preload(:school)

    {:noreply, assign(socket, :students, students)}
  end

  defp fetch_results(socket) do
    start_datetime = parse_date(socket.assigns.start_date)
    end_datetime = parse_date(socket.assigns.end_date)

    socket
    |> assign(
      :student_count,
      Repo.one(Reporting.student_count(start_datetime, end_datetime))
    )
    |> assign(
      :school_count,
      Repo.one(Reporting.school_count(start_datetime, end_datetime))
    )
    |> assign(
      :lesson_count,
      Repo.one(Reporting.lesson_count(start_datetime, end_datetime))
    )
    |> assign(
      :attendance_per_school,
      Repo.all(Reporting.attendance_per_school(start_datetime, end_datetime))
    )
    |> assign(
      :total_schools,
      Repo.all(School) |> Enum.count()
    )
    |> assign(
      :students_per_lesson,
      Reporting.students_attended(start_datetime, end_datetime)
      |> Repo.all()
      |> Repo.preload(:lessons)
      |> Enum.group_by(fn student -> Enum.count(student.lessons) end)
    )
    |> assign(
      :total_students,
      Repo.all(Student) |> Enum.count()
    )
  end

  defp parse_date(""), do: nil
  defp parse_date(nil), do: nil
  defp parse_date(date), do: Timex.parse!(date, "{YYYY}-{0M}-{0D}")
end
