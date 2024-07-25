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
  def changeset(lesson, _attrs = %{"delete" => "true"}) do
    %{Ecto.Changeset.change(lesson, delete: true) | action: :delete}
  end

  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:completed_at, :delete, :number])
    |> assoc_constraint(:student)
    |> validate_required([:completed_at, :number])
    |> validate_number(:number, greater_than: 0, less_than: 7)
  end
end
