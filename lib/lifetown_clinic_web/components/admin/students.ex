defmodule LifetownClinicWeb.Admin.Students do
  use LifetownClinicWeb, :live_component

  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def update(_assigns, socket) do
    socket =
      socket
      |> assign(:students, [])
      |> assign(
        :total_students,
        Repo.all(Student) |> Enum.count()
      )

    {:ok, socket}
  end

  def handle_event("find-student", %{"query" => query}, socket) do
    students =
      query
      |> Student.search()
      |> Repo.all()
      |> Repo.preload(:school)

    {:noreply, assign(socket, :students, students)}
  end

  def render(assigns) do
    ~H"""
    <div class="page">
      <h2>Student Management</h2>
      <div class="results">
        <div class="panel">
          <h4>Total Student Count</h4>
          <h1><%= @total_students %></h1>
        </div>
        <div class="panel">
          <h4>Student Search</h4>
          <form phx-target={@myself} phx-submit="find-student">
            <label for="query">Student Name</label>
            <input type="text" name="query" />
            <button>Search</button>
          </form>
          <ul>
            <li :for={student <- @students} class="student">
              <div><.link navigate={"/student/#{student.id}"}><%= student.name %></.link></div>
              <div>School: <%= student.school.name %></div>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
