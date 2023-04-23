defmodule LifetownClinicWeb.Confirmation do
  defstruct [:name, :student, :possible_schools]

  alias LifetownClinic.Repo
  alias LifetownClinic.Schema.{Student, School}

  def new_student(name) do
    %__MODULE__{name: name, student: %Student{name: name}, possible_schools: []}
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
