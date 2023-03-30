defmodule LifetownClinicWeb.PageController do
  use LifetownClinicWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
