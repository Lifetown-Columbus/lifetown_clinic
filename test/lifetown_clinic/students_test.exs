defmodule LifetownClinic.StudentsTest do
  use LifetownClinic.DataCase, async: true

  alias LifetownClinic.Students
  alias LifetownClinic.Schema.Student

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
    test "it can find students updated today" do
      checked_in_today = insert(:student)

      _checked_in_yesterday =
        insert(:student, %{updated_at: to_naive_dt(yesterday())})

      [result] = Students.checked_in_today()
      assert result.id == checked_in_today.id
    end

    test "it includes lessons in order" do
      it_includes_lessons_in_order(insert(:student), &Students.checked_in_today/0)
    end

    test "it includes schools and lessons" do
      it_includes_the_school(insert(:student), &Students.checked_in_today/0)
    end
  end

  describe "get/1" do
    test "it gets the student" do
      student = insert(:student)
      result = Students.get(student.id)
      assert result == student
    end

    test "it includes the school" do
      student = insert(:student)
      it_includes_the_school(student, fn -> [Students.get(student.id)] end)
    end

    test "it includes the lessons in order" do
      student = insert(:student)
      it_includes_lessons_in_order(student, fn -> [Students.get(student.id)] end)
    end
  end

  describe "by_name/1" do
    test "it can find by full name" do
      student = insert(:student)

      [result] = Students.by_name(student.name)

      assert result == student
    end

    test "its case insensitive" do
      student = insert(:student, %{name: "BOBBY"})

      [result] = Students.by_name("bobby")

      assert result == student
    end

    test "it includes the school" do
      student = insert(:student)
      it_includes_the_school(student, fn -> Students.by_name(student.name) end)
    end

    test "it includes the lessons in order" do
      student = insert(:student)
      it_includes_lessons_in_order(student, fn -> Students.by_name(student.name) end)
    end
  end

  describe "search/1" do
    test "it can find by full name" do
      student = insert(:student)

      [result] = Students.search(student.name)

      assert result == student
    end

    test "can search by partial names" do
      bobby = insert(:student, %{name: "BOBBY"})
      bob = insert(:student, %{name: "bob"})

      result = Students.search("bob")

      assert contains_all?(result, [bobby, bob])
    end

    test "it includes the school" do
      student = insert(:student)
      it_includes_the_school(student, fn -> Students.search(student.name) end)
    end

    test "it includes the lessons in order" do
      student = insert(:student)
      it_includes_lessons_in_order(student, fn -> Students.search(student.name) end)
    end
  end

  describe "add_lesson/1" do
    test "it can add a new lesson" do
      changeset = insert(:student) |> Student.changeset(%{})

      result = Students.add_lesson(changeset) |> Repo.insert_or_update!()
      [new_lesson] = result.lessons

      assert new_lesson.number == 1
    end

    test "it can add a new lesson to the existing" do
      student = insert(:student)
      existing_lesson = insert(:lesson, %{student: student}) |> Ecto.reset_fields([:student])

      changeset =
        student.id
        |> Students.get()
        |> Student.changeset(%{})

      result = Students.add_lesson(changeset) |> Repo.insert_or_update!()
      lessons = result.lessons

      assert Enum.count(lessons) == 2
      assert Enum.member?(lessons, existing_lesson)
    end
  end

  describe "remove_lesson/2" do
    test "it can remove a lesson" do
      student = insert(:student)

      insert(:lesson, %{student: student})

      [result] =
        Students.get(student.id)
        |> Student.changeset(%{})
        |> Students.remove_lesson(0)
        |> Ecto.Changeset.get_field(:lessons)

      # marks it as delete true so that when used with a Phoenix Form it will be deleted
      assert result.delete
    end
  end

  describe "by_current_lesson/1" do
    test "it should return students mapped by current lesson" do
      school = insert(:school)

      zeros =
        insert_list(2, :student, %{school: school})
        |> Enum.map(&Ecto.reset_fields(&1, [:school, :lessons]))
        |> IO.inspect()

      two = insert(:student, %{school: school}) |> Ecto.reset_fields([:school, :lessons])
      insert(:lesson, %{student: two, number: 1})
      insert(:lesson, %{student: two, number: 2})

      six = insert(:student, %{school: school}) |> Ecto.reset_fields([:school, :lessons])
      insert(:lesson, %{student: six, number: 4})
      insert(:lesson, %{student: six, number: 6})

      _other_school = insert(:student)

      result = Students.by_current_lesson(school.id)
      assert Map.keys(result) == [0, 2, 6]
      assert Map.get(result, 0) |> contains_all?(zeros)
      assert Map.get(result, 2) == [two]
      assert Map.get(result, 6) == [six]
    end
  end

  defp it_includes_the_school(student, under_test) do
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
