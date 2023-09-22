defmodule LifetownClinic.Schema.School do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "schools" do
    field :name, :string
    has_many :students, LifetownClinic.Schema.Student

    timestamps()
  end

  def starts_with(text) do
    from school in __MODULE__,
      where: ilike(school.name, ^(text <> "%")),
      select: school
  end

  def all() do
    from school in __MODULE__,
      order_by: [desc: school.name],
      select: school
  end

  @doc false
  def changeset(school, attrs) do
    school
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3)
    |> unique_constraint(:name)
  end
end
