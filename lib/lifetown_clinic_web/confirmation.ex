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
      student: %Student{name: name},
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
end
