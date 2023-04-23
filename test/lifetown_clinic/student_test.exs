defmodule LifetownClinic.StudentTest do
  use LifetownClinic.DataCase
  use Timex

  alias LifetownClinic.Schema.{Student, School, Lesson}
  alias LifetownClinic.Repo

  test "It should create a student with a school and lessons" do
    school =
      %School{name: "Really Cool High School"}
      |> Repo.insert!()

    %Student{name: "BillyB"}
    |> Repo.insert!()

    student = Repo.get_by(Student, name: "BillyB") |> Repo.preload(:school)
    assert student.name == "BillyB"

    student
    |> Student.changeset(%{})
    |> Ecto.Changeset.put_assoc(:school, school)
    |> Repo.update!()

    student =
      Student
      |> Repo.get_by(name: "BillyB")
      |> Repo.preload(:school)

    assert school == student.school
  end

  test "It can save a student with a new school" do
    %Student{name: "BillyB", school: %School{name: "Crazy Middle School"}}
    |> Repo.insert!()

    student =
      Student
      |> Repo.get_by(name: "BillyB")
      |> Repo.preload(:school)

    assert student.school.name == "Crazy Middle School"
  end

  test "It can find students created today" do
    today =
      %Student{name: "Today", inserted_at: Timex.today(:utc) |> Timex.to_naive_datetime()}
      |> Repo.insert!()

    %Student{
      name: "Yesterday",
      inserted_at: Timex.today() |> Timex.shift(days: -1) |> Timex.to_naive_datetime()
    }
    |> Repo.insert!()

    assert Student.checked_in_today()
           |> Repo.all() == [today]
  end

  test "It should find all students with a given name" do
    billy_1 =
      %Student{name: "BillyB", school: %School{name: "Crazy Middle School"}}
      |> Repo.insert!()

    billy_2 =
      %Student{name: "BillyB", school: %School{name: "Nitro High School"}}
      |> Repo.insert!()

    assert "BillyB"
           |> Student.by_name()
           |> Repo.all()
           |> Repo.preload(:school) == [billy_1, billy_2]
  end
end
