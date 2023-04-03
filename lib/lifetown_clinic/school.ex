defmodule LifetownClinic.School do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schools" do
    field :name, :string
    has_many :students, LifetownClinic.Student

    timestamps()
  end

  @doc false
  def changeset(school, attrs) do
    school
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
