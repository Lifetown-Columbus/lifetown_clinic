defmodule LifetownClinicWeb.Confirmation do
  defstruct [:name, :student, :possible_schools, :possible_students]

  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.{Student, School}

  def new(name) do
    possible_students =
      Student.by_name(name)
      |> Repo.all()
      |> Repo.preload(:school)

    %__MODULE__{
      name: name,
      student: nil,
      possible_schools: [],
      possible_students: possible_students
    }
  end

  def lookup_school(confirmation, query) do
    schools =
      query
      |> School.starts_with()
      |> Repo.all()

    confirmation
    |> Map.put(:possible_schools, schools)
  end

  def select_student(confirmation, nil) do
    Map.put(confirmation, :student, %Student{name: confirmation.name})
  end

  def select_student(confirmation, id) do
    student =
      Student
      |> Repo.get!(id)
      |> Repo.preload(:school)

    Map.put(confirmation, :student, student)
  end
end
