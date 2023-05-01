defmodule LifetownClinic.Schema.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    belongs_to :student, LifetownClinic.Schema.Student

    timestamps()
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [])
    |> assoc_constraint(:student)
    |> validate_required([])
  end
end
