defmodule LifetownClinicWeb.Admin.Students do
  use LifetownClinicWeb, :live_component

  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:cid, assigns.id)
      |> fetch_all()

    {:ok, socket}
  end

  defp fetch_all(socket) do
    socket
    |> assign(:students, [])
    |> assign(:selected_student, nil)
    |> assign(:deleting_student, nil)
    |> assign(
      :total_students,
      Repo.all(Student) |> Enum.count()
    )
  end

  def handle_event("find-student", %{"query" => query}, socket) do
    students =
      query
      |> Student.search()
      |> Repo.all()
      |> Repo.preload(:school)

    {:noreply, assign(socket, :students, students)}
  end

  def handle_event("delete_student", %{"id" => id}, socket) do
    student = Repo.get!(Student, id)
    {:noreply, assign(socket, :deleting_student, student)}
  end

  def handle_event("confirm_delete_student", _, socket) do
    Repo.delete!(socket.assigns.deleting_student)
    {:noreply, fetch_all(socket)}
  end

  def handle_event("cancel_delete_student", _, socket) do
    {:noreply, assign(socket, :deleting_student, nil)}
  end

  def handle_event("select_student", %{"id" => id}, socket) do
    student =
      Student
      |> Repo.get!(id)
      |> Repo.preload([:school, :lessons])

    {:noreply, assign(socket, :selected_student, student)}
  end

  def handle_event("cancel_student_selection", _, socket) do
    {:noreply, assign(socket, :selected_student, nil)}
  end

  def handle_info(:student_confirmed, socket) do
    {:noreply, fetch_all(socket)}
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
              <div>
                <.link phx-target={@myself} phx-click="select_student" phx-value-id={student.id}>
                  <%= student.name %>
                </.link>
              </div>
              <div>School: <%= student.school.name %></div>
            </li>
          </ul>
        </div>
      </div>

      <%= if @selected_student do %>
        <div class="modal">
          <div class="modal-body">
            <.live_component
              module={LifetownClinicWeb.StudentForm}
              student={@selected_student}
              save_callback={fn student -> send_update(__MODULE__, id: @cid, student: student) end}
              id={"student-from-#{@selected_student.id}"}
            />
            <button class="cancel" phx-target={@myself} phx-click="cancel_student_selection">
              Cancel
            </button>
            <button
              class="cancel"
              type="button"
              phx-target={@myself}
              phx-click="delete_student"
              phx-value-id={@selected_student.id}
            >
              Delete Student
            </button>
          </div>
        </div>
      <% end %>

      <%= if @deleting_student do %>
        <div class="modal">
          <div class="modal-body">
            <h2>
              <span class="warning">⚠</span>
              <span>Are you sure you want to delete </span>
              <span><%= @deleting_student.name %></span>
              <span>?</span>
            </h2>
            <button phx-target={@myself} phx-click="confirm_delete_student">Yes</button>
            <button phx-target={@myself} class="cancel" phx-click="cancel_delete_student">No</button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
