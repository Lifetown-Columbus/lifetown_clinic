defmodule LifetownClinic.ReportinTest do
  use LifetownClinic.DataCase
  alias LifetownClinic.Schema.{Student, School, Lesson}
  alias LifetownClinic.Reporting

  setup do
    last_week = days_ago(7)

    school =
      %School{name: "Really Cool High School"}
      |> Repo.insert!()

    other_school =
      %School{name: "Another Really Cool High School"}
      |> Repo.insert!()

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
    last_week = days_ago(7)
    last_month = days_ago(30)
    yesterday = days_ago(1)
    today = Timex.now() |> Timex.to_datetime()

    assert 3 == Repo.one(Reporting.student_count(nil, nil))
    assert 2 == Repo.one(Reporting.student_count(yesterday, nil))
    assert 3 == Repo.one(Reporting.student_count(last_week, nil))
    assert 2 == Repo.one(Reporting.student_count(yesterday, today))
    assert 3 == Repo.one(Reporting.student_count(last_week, today))
    assert 1 == Repo.one(Reporting.student_count(last_month, last_week))
    assert 3 == Repo.one(Reporting.student_count(nil, today))
    assert 1 == Repo.one(Reporting.student_count(nil, last_week))
  end

  test "It should return school count for a given date range" do
    last_week = days_ago(7)
    last_month = days_ago(30)
    yesterday = days_ago(1)
    today = Timex.now() |> Timex.to_datetime()

    assert 2 == Repo.one(Reporting.school_count(nil, nil))
    assert 1 == Repo.one(Reporting.school_count(yesterday, nil))
    assert 2 == Repo.one(Reporting.school_count(last_week, nil))
    assert 1 == Repo.one(Reporting.school_count(yesterday, today))
    assert 2 == Repo.one(Reporting.school_count(last_week, today))
    assert 1 == Repo.one(Reporting.school_count(last_month, last_week))
    assert 2 == Repo.one(Reporting.school_count(nil, today))
    assert 1 == Repo.one(Reporting.school_count(nil, last_week))
  end

  test "It should return lesson count for a given date range" do
    last_week = days_ago(7)
    last_month = days_ago(30)
    yesterday = days_ago(1)
    today = Timex.now() |> Timex.to_datetime()

    assert 4 == Repo.one(Reporting.lesson_count(nil, nil))
    assert 2 == Repo.one(Reporting.lesson_count(yesterday, nil))
    assert 4 == Repo.one(Reporting.lesson_count(last_week, nil))
    assert 2 == Repo.one(Reporting.lesson_count(yesterday, today))
    assert 4 == Repo.one(Reporting.lesson_count(last_week, today))
    assert 2 == Repo.one(Reporting.lesson_count(last_month, last_week))
    assert 4 == Repo.one(Reporting.lesson_count(nil, today))
    assert 2 == Repo.one(Reporting.lesson_count(nil, last_week))
  end

  test "It should return students per lessons completed" do
  end

  test "It should return student attendance per school", %{
    school: school,
    other_school: other_school
  } do
    last_week = days_ago(7)
    last_month = days_ago(30)
    yesterday = days_ago(1)
    today = Timex.now() |> Timex.to_datetime()

    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, nil))

    assert [%{school: school, attendance: 2}] ==
             Repo.all(Reporting.attendance_per_school(yesterday, nil))

    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(last_week, nil))

    assert [%{school: school, attendance: 2}] ==
             Repo.all(Reporting.attendance_per_school(yesterday, today))

    assert [%{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(last_month, last_week))

    assert [%{school: school, attendance: 2}, %{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, today))

    assert [%{school: other_school, attendance: 1}] ==
             Repo.all(Reporting.attendance_per_school(nil, last_week))
  end

  defp days_ago(count) do
    Timex.today() |> Timex.shift(days: -count) |> Timex.to_datetime()
  end

  defp create_student(school, name) do
    %Student{}
    |> Student.changeset(%{name: name, school_id: school.id})
    |> Repo.insert!()
  end

  defp complete_lesson(student) do
    today = Timex.today() |> Timex.to_datetime()

    student
    |> complete_lesson(today)
  end

  defp complete_lesson(student, date) do
    student
    |> Ecto.build_assoc(:lessons)
    |> Lesson.changeset(%{inserted_at: date})
    |> Repo.insert!()

    student
  end
end
