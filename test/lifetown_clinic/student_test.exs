defmodule LifetownClinic.StudentTest do
  use LifetownClinic.DataCase
  use Timex

  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

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
    today = insert(:student, %{name: "Today", school: school})

    _yesterday =
      insert(:student, %{
        updated_at: Timex.today() |> Timex.shift(days: -1) |> Timex.to_naive_datetime(),
        school: school
      })

    assert Student.checked_in_today()
           |> Repo.all()
           |> Enum.map(& &1.id) == [today.id]
  end

  test "It should find all students with a given name" do
    billy_1 = insert(:student, %{name: "BillyB"})
    billy_2 = insert(:student, %{name: "BillyB"})

    assert "BillyB" |> Student.by_name() |> Repo.all() |> Enum.map(& &1.id) ==
             [billy_1.id, billy_2.id]
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
