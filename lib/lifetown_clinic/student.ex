defmodule LifetownClinic.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :name, :string
    belongs_to :school, LifetownClinic.School
    has_many :lessons, LifetownClinic.Lesson

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
