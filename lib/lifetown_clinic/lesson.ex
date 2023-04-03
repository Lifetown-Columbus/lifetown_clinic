defmodule LifetownClinic.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    belongs_to :student, LifetownClinic.Student

    timestamps()
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [])
    |> validate_required([])
  end
end
