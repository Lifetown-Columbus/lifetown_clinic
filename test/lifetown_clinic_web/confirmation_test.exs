defmodule LifetownClinicWeb.ConfirmationTest do
  use LifetownClinic.DataCase

  alias LifetownClinicWeb.Confirmation
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.Student

  test "it should create a new confirmation" do
    result = Confirmation.new("abc123", "Billy")
    assert result.id == "abc123"
    assert result.name == "Billy"
    assert result.student == nil
    assert result.possible_students == []
  end

  test "it should lookup possible students when a new confirmation is created with a given name" do
    student = insert(:student, %{name: "Billy"})

    result = Confirmation.new("abc123", "Billy")
    assert result.name == "Billy"
    assert result.student == nil
    assert result.possible_students == [student]
  end

  test "it should allow you to select a new student" do
    result =
      "abc123"
      |> Confirmation.new("Billy")
      |> Confirmation.select_student(nil)

    assert result.student == %Student{name: "Billy", lessons: []}
  end

  test "it should allow you to select an existing student" do
    student =
      %Student{name: "Billy", school: build(:school)}
      |> Repo.insert!()
      |> Repo.preload(:school)
      |> Repo.preload(:lessons)

    result =
      "some-id"
      |> Confirmation.new("Billy")
      |> Confirmation.select_student(student.id)

    assert result.student == student
  end
end
