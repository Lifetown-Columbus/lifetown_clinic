defmodule LifetownClinic.Schema.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    belongs_to :student, LifetownClinic.Schema.Student

    field :delete, :boolean, virtual: true, default: false

    timestamps()
  end

  @doc false
  def changeset(lesson, attrs) do
    changeset =
      lesson
      |> cast(attrs, [:inserted_at, :delete])
      |> assoc_constraint(:student)
      |> validate_required([])

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
