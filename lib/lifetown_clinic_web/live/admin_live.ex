defmodule LifetownClinicWeb.AdminLive do
  use LifetownClinicWeb, :live_view

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:start_date, nil)
      |> assign(:end_date, nil)

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

    {:noreply, socket}
  end
end
