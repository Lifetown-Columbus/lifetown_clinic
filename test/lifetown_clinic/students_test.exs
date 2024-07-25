defmodule LifetownClinic.StudentsTest do
  use LifetownClinic.DataCase, async: true

  alias LifetownClinic.Students

  describe "save_student/2" do
    setup do
      yesterday = Timex.today() |> Timex.shift(days: -1) |> Timex.to_naive_datetime()
      %{student: insert(:student, %{updated_at: yesterday})}
    end

    test "it saves the student", %{student: student} do
      {:ok, result} = Students.save_student(student, %{name: "BobbyTables"})

      assert result.name == "BobbyTables"
    end

    test "it validates the changes", %{student: student} do
      {:error, changeset} = Students.save_student(student, %{name: nil})

      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
    end

    test "it updates the timestamps", %{student: student} do
      {:ok, result} = Students.save_student(student, %{})

      assert Timex.day(result.updated_at) == Timex.today() |> Timex.day()
    end
  end
end
