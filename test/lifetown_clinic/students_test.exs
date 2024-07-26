defmodule LifetownClinic.StudentsTest do
  use LifetownClinic.DataCase, async: true

  alias LifetownClinic.Students

  describe "save_student/2" do
    setup do
      yesterday = to_naive_dt(yesterday())
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
      checked_in_today = insert(:student)

      _checked_in_yesterday =
        insert(:student, %{updated_at: to_naive_dt(yesterday())})

      [result] = Students.checked_in_today()
      assert result.id == checked_in_today.id
    end

    test "It includes lessons in order" do
      it_includes_lessons_in_order(insert(:student), &Students.checked_in_today/0)
    end

    test "It includes schools and lessons" do
      it_includes_the_school(insert(:student), &Students.checked_in_today/0)
    end
  end

  describe "get/1" do
    test "It gets the student" do
      student = insert(:student)
      result = Students.get(student.id)
      assert result == student
    end

    test "It includes the school" do
      student = insert(:student)
      it_includes_the_school(student, fn -> [Students.get(student.id)] end)
    end

    test "It includes the lessons in order" do
      student = insert(:student)
      it_includes_lessons_in_order(student, fn -> [Students.get(student.id)] end)
    end
  end

  defp it_includes_the_school(student, under_test) do
    lessons =
      insert_list(2, :lesson, %{student: student})
      |> Enum.map(&Ecto.reset_fields(&1, [:school, :student]))

    [result] = under_test.()

    assert result.school == student.school
  end

  defp it_includes_lessons_in_order(student, under_test) do
    first_lesson =
      insert(:lesson, %{student: student, completed_at: to_naive_dt(last_week())})
      |> Ecto.reset_fields([:student])

    second_lesson =
      insert(:lesson, %{student: student, completed_at: to_naive_dt(yesterday())})
      |> Ecto.reset_fields([:student])

    third_lesson =
      insert(:lesson, %{student: student, completed_at: to_naive_dt(today())})
      |> Ecto.reset_fields([:student])

    [result] = under_test.()

    assert result.lessons == [first_lesson, second_lesson, third_lesson]
  end
end
