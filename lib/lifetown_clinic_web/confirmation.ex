defmodule LifetownClinicWeb.Confirmation do
  defstruct [:name, :student, :possible_schools, :possible_students]

  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.{Student, School}

  def new(name) do
    possible_students =
      Student.by_name(name)
      |> Repo.all()
      |> Repo.preload(:school)
      |> Repo.preload(:lessons)

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
    Map.put(confirmation, :student, %Student{
      name: confirmation.name,
      school: %School{name: nil},
      lessons: []
    })
  end

  def select_student(confirmation, id) do
    student =
      Student
      |> Repo.get!(id)
      |> Repo.preload(:school)
      |> Repo.preload(:lessons)

    confirmation
    |> Map.put(:student, student)
    |> Map.put(:name, student.name)
  end

  def update_name(confirmation, name) do
    Map.put(confirmation, :name, name)
  end
end
