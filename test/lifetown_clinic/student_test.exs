defmodule LifetownClinic.StudentTest do
  use LifetownClinic.DataCase

  alias LifetownClinic.{Student, School, Lesson}
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
end
