defmodule LifetownClinic.ReportingTest do
  use LifetownClinic.DataCase

  alias LifetownClinic.Schema.Lesson
  alias LifetownClinic.Reporting

  setup do
    last_week = days_ago(7)

    school = insert(:school, %{name: "AA Really Cool High School"})
    other_school = insert(:school, %{name: "BB Another Really Cool High School"})

    school
    |> create_student("Bob")
    |> complete_lesson()

    school
    |> create_student("Fred")
    |> complete_lesson()

    other_school
    |> create_student("Sally")
    |> complete_lesson(last_week)
    |> complete_lesson(last_week)

    %{school: school, other_school: other_school}
  end

  test "It should return student count for a given date range" do
    assert 3 == Repo.one(Reporting.student_count(nil, nil))
    assert 2 == Repo.one(Reporting.student_count(yesterday(), nil))
    assert 3 == Repo.one(Reporting.student_count(last_week(), nil))
    assert 2 == Repo.one(Reporting.student_count(yesterday(), today()))
    assert 3 == Repo.one(Reporting.student_count(last_week(), today()))
    assert 1 == Repo.one(Reporting.student_count(last_month(), last_week()))
    assert 3 == Repo.one(Reporting.student_count(nil, today()))
    assert 1 == Repo.one(Reporting.student_count(nil, last_week()))
  end

  test "It should return school count for a given date range" do
    assert 2 == Repo.one(Reporting.school_count(nil, nil))
    assert 1 == Repo.one(Reporting.school_count(yesterday(), nil))
    assert 2 == Repo.one(Reporting.school_count(last_week(), nil))
    assert 1 == Repo.one(Reporting.school_count(yesterday(), today()))
    assert 2 == Repo.one(Reporting.school_count(last_week(), today()))
    assert 1 == Repo.one(Reporting.school_count(last_month(), last_week()))
    assert 2 == Repo.one(Reporting.school_count(nil, today()))
    assert 1 == Repo.one(Reporting.school_count(nil, last_week()))
  end

  test "It should return lesson count for a given date range" do
    assert 4 == Repo.one(Reporting.lesson_count(nil, nil))
    assert 2 == Repo.one(Reporting.lesson_count(yesterday(), nil))
    assert 4 == Repo.one(Reporting.lesson_count(last_week(), nil))
    assert 2 == Repo.one(Reporting.lesson_count(yesterday(), today()))
    assert 4 == Repo.one(Reporting.lesson_count(last_week(), today()))
    assert 2 == Repo.one(Reporting.lesson_count(last_month(), last_week()))
    assert 4 == Repo.one(Reporting.lesson_count(nil, today()))
    assert 2 == Repo.one(Reporting.lesson_count(nil, last_week()))
  end

  test "It should return the lessons completed for a given date range" do
    assert 4 == Enum.count(Repo.all(Reporting.lessons_completed(nil, nil)))
    assert 2 == Enum.count(Repo.all(Reporting.lessons_completed(yesterday(), today())))
    assert 2 == Enum.count(Repo.all(Reporting.lessons_completed(last_month(), last_week())))
    assert 2 == Enum.count(Repo.all(Reporting.lessons_completed(nil, last_week())))

    result = Repo.all(Reporting.lessons_completed(nil, nil))
    assert Enum.all?(result, fn l -> %Lesson{} = l end)
  end

  test "It should return student attendance per school in alphabetical order", %{
    school: school,
    other_school: other_school
  } do
    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, nil))

    assert [%{school: school, attendance: 2}] ==
             Repo.all(Reporting.attendance_per_school(yesterday(), nil))

    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(last_week(), nil))

    assert [%{school: school, attendance: 2}] ==
             Repo.all(Reporting.attendance_per_school(yesterday(), today()))

    assert [%{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(last_month(), last_week()))

    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, today()))

    assert [%{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, last_week()))
  end

  test "It should return students that attended" do
    assert ["Bob", "Fred", "Sally"] ==
             Reporting.students_attended(nil, nil)
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))

    assert ["Bob", "Fred", "Sally"] ==
             Reporting.students_attended(nil, today())
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))

    assert ["Bob", "Fred", "Sally"] ==
             Reporting.students_attended(last_week(), today())
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))

    assert ["Bob", "Fred", "Sally"] ==
             Reporting.students_attended(last_week(), nil)
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))

    assert ["Bob", "Fred"] ==
             Reporting.students_attended(yesterday(), today())
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))

    assert ["Sally"] ==
             Reporting.students_attended(last_month(), last_week())
             |> Repo.all()
             |> Enum.map(&Map.get(&1, :name))
  end

  defp create_student(school, name) do
    insert(:student, %{name: name, school: school})
  end

  defp complete_lesson(student), do: complete_lesson(student, Timex.today())

  defp complete_lesson(student, date) do
    insert(:lesson, %{student: student, completed_at: date})
    student
  end
end
