defmodule LifetownClinicWeb.Components.ReceptionLiveTest do
  use LifetownClinicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LifetownClinic.Reception

  test "it should render the page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/reception")
    assert html =~ "Awaiting Confirmation"
    assert html =~ "Confirmed"
  end

  test "it should render a student that has checked in", %{conn: conn} do
    Reception.check_in("Billy")

    {:ok, view, _html} = live(conn, "/reception")

    assert view
           |> element("ul#checked-in li")
           |> render() =~ "Billy"
  end
end
