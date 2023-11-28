defmodule LifetownClinicWeb.KioskLive do
  use LifetownClinicWeb, :live_view
  alias LifetownClinic.Reception

  def mount(_params, _session, socket) do
    {:ok, reset_page(socket)}
  end

  def handle_event("validate", %{"name" => text}, socket) do
    {:noreply, assign(socket, :name, text)}
  end

  def handle_event("check_in", %{"name" => name}, socket) do
    case Reception.check_in(name) do
      :ok ->
        {:noreply, reset_page(socket)}

      {:error, msg} ->
        {:noreply, assign(socket, :error, msg)}
    end
  end

  defp reset_page(socket) do
    socket
    |> assign(:name, "")
    |> assign(:error, nil)
  end
end
