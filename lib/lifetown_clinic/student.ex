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
    |> validate_format(:name, ~r/\A[A-Z][a-zA-Z]*[A-Z]\d?\z/,
      message:
        "Name must start with a capital letter and end with a captial letter or optional number. (E.G. FranD, BillB2)"
    )
    |> validate_required([:name])
  end
end
