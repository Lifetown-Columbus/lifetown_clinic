defmodule LifetownClinic.Students do
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Repo

  def save_student(params, student) do
    student
    |> Student.changeset(params)
    # |> maybe_find_school(school)
    # force updated_at to change to now
    |> Repo.insert_or_update(force: true)
  end

  defp maybe_find_school(changeset, school_name) do
    case Repo.get_by(School, name: school_name) do
      nil ->
        Student.changeset(changeset, %{school: %{id: 1, name: school_name}})

      school ->
        Ecto.Changeset.put_assoc(changeset, :school, school)
    end
  end
end
