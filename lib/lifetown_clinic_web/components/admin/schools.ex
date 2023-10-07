defmodule LifetownClinicWeb.Admin.Schools do
  use LifetownClinicWeb, :live_component

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Repo

  def update(_assigns, socket) do
    socket =
      socket
      |> assign(:schools, [])
      |> total_schools()

    {:ok, socket}
  end

  def handle_event("add-school", %{"school-name" => school_name}, socket) do
    %School{}
    |> School.changeset(%{"name" => school_name})
    |> Repo.insert()

    {:noreply, total_schools(socket)}
  end

  def handle_event("find-school", %{"query" => query}, socket) do
    schools =
      query
      |> School.search()
      |> Repo.all()
      |> Repo.preload(:students)

    {:noreply, assign(socket, :schools, schools)}
  end

  # TODO add phoenix form for error handling to add school form
  def render(assigns) do
    ~H"""
    <div class="page">
      <h2>School Management</h2>
      <div class="results">
        <div class="panel">
          <h4>Total School Count</h4>
          <h1><%= @total_schools %></h1>

          <form phx-target={@myself} phx-submit="add-school">
            <label for="school-name">School Name</label>
            <input type="text" name="school-name" />
            <button>Add School</button>
          </form>
        </div>
        <div class="panel">
          <h4>School Search</h4>
          <form phx-target={@myself} phx-submit="find-school">
            <label for="query">School Name</label>
            <input type="text" name="query" />
            <button>Search</button>
          </form>
          <ul>
            <li :for={school <- @schools} class="school">
              <div><.link navigate={"/school/#{school.id}"}><%= school.name %></.link></div>
              <div>Students: <%= Enum.count(school.students) %></div>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  defp total_schools(socket) do
    assign(
      socket,
      :total_schools,
      Repo.all(School) |> Enum.count()
    )
  end
end
