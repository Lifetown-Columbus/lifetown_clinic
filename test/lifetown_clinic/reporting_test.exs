defmodule LifetownClinic.ReportinTest do
  use LifetownClinic.DataCase
  alias LifetownClinic.Schema.{Student, School, Lesson}
  alias LifetownClinic.Reporting

  setup do
    last_week = days_ago(7)

    school =
      %School{name: "Really Cool High School"}
      |> Repo.insert!()

    school
    |> create_student("Bob")
    |> check_in()

    school
    |> create_student("Fred")
    |> check_in()

    %School{name: "Another Really Cool High School"}
    |> Repo.insert!()
    |> create_student("Sally")
    |> check_in(last_week)
    |> check_in(last_week)

    :ok
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

  defp days_ago(count) do
    Timex.today() |> Timex.shift(days: -count) |> Timex.to_datetime()
  end

  defp create_student(school, name) do
    %Student{}
    |> Student.changeset(%{name: name})
    |> Ecto.Changeset.put_assoc(:school, school)
    |> Repo.insert!()
  end

  defp check_in(student) do
    today = Timex.today() |> Timex.to_datetime()

    student
    |> check_in(today)
  end

  defp check_in(student, date) do
    student
    |> Ecto.build_assoc(:lessons)
    |> Lesson.changeset(%{inserted_at: date})
    |> Repo.insert!()

    student
  end
end
