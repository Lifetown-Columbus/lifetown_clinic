defmodule LifetownClinicWeb.Admin.Reports do
  use LifetownClinicWeb, :live_component

  alias LifetownClinic.Repo
  alias LifetownClinic.Reporting

  def update(_assigns, socket) do
    socket =
      socket
      |> assign(:start_date, nil)
      |> assign(:end_date, nil)
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

  def render(assigns) do
    ~H"""
    <div class="page">
      <h2>Reporting</h2>
      <div id="filters">
        <form class="filters" phx-target={@myself} phx-change="filter_updated">
          <label for="start-date">After:</label>
          <input type="date" name="start-date" value={@start_date} />
          <label for="end-date">Before:</label>
          <input type="date" name="end-date" value={@end_date} />
        </form>
      </div>
      <div class="results">
        <div class="panel">
          <h4>Students Attended</h4>
          <h1><%= @student_count %></h1>
        </div>
        <div class="panel">
          <h4>Schools Attended</h4>
          <h1><%= @school_count %></h1>
        </div>
        <div class="panel">
          <h4>Lessons Completed</h4>
          <h1><%= @lesson_count %></h1>
        </div>
      </div>
      <div class="results">
        <div class="panel">
          <h4>Student Progress</h4>
          <table>
            <tr>
              <th>Lesson Completed</th>
              <th>Students Count</th>
            </tr>
            <tr>
              <td>6</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 6, [])) %></td>
            </tr>
            <tr>
              <td>5</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 5, [])) %></td>
            </tr>
            <tr>
              <td>4</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 4, [])) %></td>
            </tr>
            <tr>
              <td>3</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 3, [])) %></td>
            </tr>
            <tr>
              <td>2</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 2, [])) %></td>
            </tr>
            <tr>
              <td>1</td>
              <td><%= Enum.count(Map.get(@lessons_per_number, 1, [])) %></td>
            </tr>
          </table>
        </div>
        <div class="panel">
          <h4>Student Attendance per School</h4>
          <table>
            <tr>
              <th>School Name</th>
              <th>Students Attended</th>
            </tr>
            <%= for record <- @attendance_per_school do %>
              <tr>
                <td>
                  <.link navigate={"/school/#{record.school.id}"}><%= record.school.name %></.link>
                </td>
                <td><%= record.attendance %></td>
              </tr>
            <% end %>
          </table>
        </div>
      </div>
    </div>
    """
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
      :lessons_per_number,
      Reporting.lessons_completed(start_datetime, end_datetime)
      |> Repo.all()
      |> Enum.group_by(fn lesson -> lesson.number end)
    )
  end

  defp parse_date(""), do: nil
  defp parse_date(nil), do: nil
  defp parse_date(date), do: Timex.parse!(date, "{YYYY}-{0M}-{0D}")
end
