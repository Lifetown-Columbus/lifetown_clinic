defmodule LifetownClinicWeb.StudentFormTest do
  use LifetownClinicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Phoenix.Component

  alias LifetownClinic.Schema.{School, Student}
  alias LifetownClinic.Repo

  setup %{conn: conn} do
    other_school = %School{name: "Another School"} |> Repo.insert!()
    school = %School{name: "Test School"} |> Repo.insert!()
    student = %Student{name: "Test Student", school_id: school.id} |> Repo.insert!()
    %{school: school, other_school: other_school, student: student, conn: conn}
  end

  test "it renders the form with the correct data", %{conn: conn, student: student} do
    {:ok, _view, html} = live(conn, ~p"/student/#{student.id}")
    assert html =~ "Name"
    assert html =~ "Test Student"
    assert html =~ "School"
    assert html =~ "Test School"
  end

  test "it allows you to change the school", %{conn: conn, student: student, other_school: school} do
    {:ok, view, _html} = live(conn, ~p"/student/#{student.id}")

    assert view
           |> element("form")
           |> render_submit(%{student: %{school_id: school.id}}) =~ "Another School"
  end

  test "it allows you change the student name", %{conn: conn, student: student} do
    {:ok, view, _html} = live(conn, ~p"/student/#{student.id}")

    assert view
           |> form("form")
           |> render_change(%{student: %{name: "Billy"}}) =~ "Billy"

    assert view
           |> form("form")
           |> render_submit() =~ "Billy"
  end
end
