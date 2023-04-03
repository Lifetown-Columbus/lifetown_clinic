defmodule LifetownClinic.School do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "schools" do
    field :name, :string
    has_many :students, LifetownClinic.Student

    timestamps()
  end

  def starts_with(text) do
    from school in __MODULE__,
      where: ilike(school.name, ^(text <> "%")),
      select: school
  end

  @doc false
  def changeset(school, attrs) do
    school
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
