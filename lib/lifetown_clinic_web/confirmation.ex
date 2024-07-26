defmodule LifetownClinicWeb.Confirmation do
  defstruct [:id, :name, :student, :possible_students]

  alias LifetownClinic.Students
  alias LifetownClinic.Schema.Student

  def new(id, name) do
    possible_students = Students.by_name_with_lessons(name)

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
    student = Students.get(id)

    confirmation
    |> Map.put(:student, student)
    |> Map.put(:name, student.name)
  end

  def update_name(confirmation, name) do
    Map.put(confirmation, :name, name)
  end
end
