defmodule LifetownClinic.Schema.Student do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LifetownClinic.Schema.{Lesson, School}

  schema "students" do
    field :name, :string
    belongs_to :school, School
    has_many :lessons, Lesson

    timestamps()
  end

  def checked_in_today() do
    today = DateTime.to_date(Timex.local())

    from s in __MODULE__,
      where:
        fragment(
          "date(updated_at AT TIME ZONE 'UTC' AT TIME ZONE ?) = ?",
          ^Timex.Timezone.Local.lookup(),
          ^today
        ),
      select: s
  end

  def by_name(name) do
    from s in __MODULE__,
      where: s.name == ^name,
      select: s
  end

  @doc false
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:school, required: true, with: &School.changeset/2)
    |> assoc_constraint(:school)
  end
end
