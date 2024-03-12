defmodule LifetownClinicWeb.StudentFormTest do
  use LifetownClinicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Phoenix.Component

  alias LifetownClinic.Schema.{School, Student}
  alias LifetownClinic.Repo

  setup %{conn: conn} do
    school = %School{name: "Test School"} |> Repo.insert!()
    student = %Student{name: "Test Student", school_id: school.id} |> Repo.insert!()
    %{school: school, student: student, conn: conn}
  end

  test "it renders the form", %{conn: conn, student: student} do
    {:ok, view, html} = live(conn, ~p"/student/#{student.id}")
    assert html =~ "Name"
    assert html =~ "School"
  end
end
