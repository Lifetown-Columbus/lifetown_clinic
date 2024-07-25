defmodule LifetownClinic.StudentTest do
  use LifetownClinic.DataCase
  use Timex

  alias LifetownClinic.Schema.{School, Student}
  alias LifetownClinic.Repo

  test "It should create a student with a school and lessons" do
    school = insert(:school, %{name: "Really Cool High School"})

    %Student{}
    |> Student.changeset(%{name: "BillyB", school_id: school.id})
    |> Repo.insert!()

    student = Repo.get_by(Student, name: "BillyB") |> Repo.preload(:school)

    assert student.name == "BillyB"
    assert student.school == school
  end

  test "It can save a student with a new school" do
    school = insert(:school)

    %Student{name: "BillyB", school: school}
    |> Repo.insert!()

    student =
      Student
      |> Repo.get_by(name: "BillyB")
      |> Repo.preload(:school)

    assert student.school.name == school.name
  end

  test "It can find students updated today" do
    school = insert(:school)

    today =
      %Student{}
      |> Student.changeset(%{name: "Today", school_id: school.id})
      |> Repo.insert!(force: true)

    %Student{
      updated_at: Timex.today() |> Timex.shift(days: -1) |> Timex.to_naive_datetime()
    }
    |> Student.changeset(%{name: "Yesterday", school_id: school.id})
    |> Repo.insert!()

    assert Student.checked_in_today()
           |> Repo.all() == [today]
  end

  test "It should find all students with a given name" do
    billy_1 =
      %Student{name: "BillyB", school: build(:school)}
      |> Repo.insert!()

    billy_2 =
      %Student{name: "BillyB", school: build(:school)}
      |> Repo.insert!()

    assert "BillyB"
           |> Student.by_name()
           |> Repo.all()
           |> Repo.preload(:school) == [billy_1, billy_2]
  end

  test "It can get students by school and current lesson" do
    # current lesson is defined by the max lesson number completed
    #
    # school =
    #   %School{name: "Really Cool High School"}
    #   |> Repo.insert!()
    #
    # billy =
    #   %Student{}
    #   |> Student.changeset(%{name: "Billy", school_id: school.id})
    #   |> Repo.insert!(force: true)
    #
    # bobby =
    #   %Student{}
    #   |> Student.changeset(%{name: "Bobby", school_id: school.id})
    #   |> Repo.insert!(force: true)
  end
end
