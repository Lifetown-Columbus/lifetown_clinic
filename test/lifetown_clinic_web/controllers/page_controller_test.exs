defmodule LifetownClinicWeb.PageControllerTest do
  use LifetownClinicWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Kiosk"
  end
end
