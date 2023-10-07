defmodule LifetownClinicWeb.AdminLive do
  use LifetownClinicWeb, :live_view

  def mount(_params, _, socket) do
    case socket.assigns.live_action do
      :reports ->
        {:ok, assign(socket, :page, LifetownClinicWeb.Admin.Reports)}

      :schools ->
        {:ok, assign(socket, :page, LifetownClinicWeb.Admin.Schools)}

      :students ->
        {:ok, assign(socket, :page, LifetownClinicWeb.Admin.Students)}

      _ ->
        {:ok, push_navigate(socket, to: "/admin/reports")}
    end
  end
end
