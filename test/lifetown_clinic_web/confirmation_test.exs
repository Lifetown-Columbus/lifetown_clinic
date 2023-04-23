defmodule LifetownClinicWeb.ConfirmationTest do
  use LifetownClinic.DataCase

  alias LifetownClinicWeb.Confirmation
  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student

  test "it should create a new confirmation" do
    result = Confirmation.new("Billy")
    assert result.name == "Billy"
    assert result.student == %Student{name: "Billy"}
    assert result.possible_schools == []
    assert result.possible_students == []
  end

  test "it should lookup schools that start with some query" do
    school =
      %School{name: "Nitro High School"}
      |> Repo.insert!()

    assert Confirmation.new("Billy")
           |> Confirmation.lookup_school("ni")
           |> Map.get(:possible_schools) == [school]
  end

  test "it should lookup possible students when a new confirmation is created with a given name" do
    student =
      %Student{name: "Billy", school: %School{name: "Nitro High School"}}
      |> Repo.insert!()

    result = Confirmation.new("Billy")
    assert result.name == "Billy"
    assert result.student == %Student{name: "Billy"}
    assert result.possible_schools == []
    assert result.possible_students == [student]
  end
end
