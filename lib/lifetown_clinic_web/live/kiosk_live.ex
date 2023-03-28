defmodule LifetownClinicWeb.KioskLive do
  use LifetownClinicWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("check_in", %{"name" => _name}, socket) do

  end
end
