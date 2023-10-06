defmodule LifetownClinicWeb.Confirmation do
  defstruct [:id, :name, :student, :possible_students]

  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.Student

  def new(id, name) do
    possible_students =
      Student.by_name(name)
      |> Repo.all()
      |> Repo.preload(:school)
      |> Repo.preload(:lessons)

    %__MODULE__{
      id: id,
      name: name,
      student: nil,
      possible_students: possible_students
    }
  end

  def select_student(confirmation, nil) do
    Map.put(confirmation, :student, %Student{
      name: confirmation.name,
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
