defmodule LifetownClinicWeb.KioskLive do
  use LifetownClinicWeb, :live_view
  alias LifetownClinic.FrontDesk

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :name, "")}
  end

  def handle_event("validate", %{"name" => text}, socket) do
    {:noreply, assign(socket, :name, text)}
  end

  def handle_event("check_in", %{"name" => name}, socket) do
    :ok = FrontDesk.check_in(name)

    {:noreply, assign(socket, :name, "")}
  end
end
