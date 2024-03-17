defmodule LifetownClinic.Schema.Student do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LifetownClinic.Schema.{Lesson, School}

  schema "students" do
    field :name, :string
    belongs_to :school, School, on_replace: :nilify

    has_many :lessons, Lesson,
      on_delete: :delete_all,
      preload_order: [asc: :completed_at]

    timestamps()
  end

  # TODO this should check lessons in case something else changed
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

  def by_lesson_number(school_id, 0) do
    from s in __MODULE__,
      where: s.school_id == ^school_id,
      where: fragment("NOT EXISTS (SELECT 1 FROM lessons l WHERE l.student_id = ?)", s.id),
      select: s
  end

  def by_lesson_number(school_id, lesson_number) do
    from s in __MODULE__,
      where: s.school_id == ^school_id,
      join: l in assoc(s, :lessons),
      where: l.number == ^lesson_number,
      distinct: true,
      select: s
  end

  def search(text) do
    from student in __MODULE__,
      where: ilike(student.name, ^("%" <> text <> "%")),
      select: student
  end

  @doc false
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, [:name, :school_id])
    |> cast_assoc(:school, with: &School.changeset/2)
    |> cast_assoc(:lessons, with: &Lesson.changeset/2)
    |> validate_required([:name, :school_id])
    |> assoc_constraint(:school)
    |> unique_constraint([:name, :school_id])
  end
end
