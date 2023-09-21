defmodule LifetownClinic.Schema.Student do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LifetownClinic.Schema.{Lesson, School}

  schema "students" do
    field :name, :string
    belongs_to :school, School, on_replace: :nilify
    has_many :lessons, Lesson, on_delete: :delete_all

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
      where: ilike(s.name, ^name),
      select: s
  end

  @doc false
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, [:name, :school_id])
    |> cast_assoc(:school, with: &School.changeset/2)
    |> validate_required([:name, :school_id])
    |> validate_length(:lessons, max: 6)
    |> assoc_constraint(:school)
    |> unique_constraint([:name, :school_id])
  end
end
