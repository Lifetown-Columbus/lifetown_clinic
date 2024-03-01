defmodule LifetownClinic.Schema.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    belongs_to :student, LifetownClinic.Schema.Student

    field :delete, :boolean, virtual: true, default: false
    field :completed_at, :date, default: Timex.today()
    field :number, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(lesson, attrs) do
    changeset =
      lesson
      |> cast(attrs, [:completed_at, :delete, :number])
      |> assoc_constraint(:student)
      |> validate_required([:completed_at, :number])
      |> validate_number(:number, greater_than: 0, less_than: 7)

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
