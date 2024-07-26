defmodule LifetownClinic.StudentsTest do
  use LifetownClinic.DataCase, async: true

  alias LifetownClinic.Students

  describe "save_student/2" do
    setup do
      yesterday = Timex.to_naive_datetime(yesterday())
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

  describe "checked_in_today/0" do
    test "It can find students updated today" do
      school = insert(:school)
      today = insert(:student, %{name: "Today", school: school})

      _yesterday =
        insert(:student, %{
          updated_at: Timex.to_naive_datetime(yesterday()),
          school: school
        })

      assert Students.checked_in_today() |> Enum.map(& &1.id) == [today.id]
    end

    test "It includes schools and lessons" do
      school = insert(:school)
      student = insert(:student, %{name: "Today", school: school})

      lessons =
        insert_list(2, :lesson, %{student: student})
        |> Enum.map(&Ecto.reset_fields(&1, [:school, :student]))

      [result] = Students.checked_in_today()
      assert result.school == school

      assert contains_all?(result.lessons, lessons)
    end

    test "It includes lessons in the order they were completed" do
    end
  end
end
