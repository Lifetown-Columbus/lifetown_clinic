defmodule LifetownClinicWeb.AdminLive do
  use LifetownClinicWeb, :live_view

  alias LifetownClinic.Reporting
  alias LifetownClinic.Repo

  def mount(_, _, socket) do
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

  defp fetch_results(socket) do
    start_datetime = parse_date(socket.assigns.start_date)
    end_datetime = parse_date(socket.assigns.end_date |> IO.inspect())

    socket
    |> assign(
      :total_student_count,
      Repo.one(Reporting.student_count(start_datetime, end_datetime))
    )
    |> assign(:total_school_count, Repo.one(Reporting.school_count()))
  end

  defp parse_date(""), do: nil
  defp parse_date(nil), do: nil
  defp parse_date(date), do: Timex.parse!(date, "{YYYY}-{0M}-{0D}")
end
