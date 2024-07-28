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

  # TODO change this to use a new field called last_check_in
  def checked_in_today() do
    today = DateTime.to_date(Timex.local())

    from s in __MODULE__,
      where:
        fragment(
          "date(updated_at AT TIME ZONE 'UTC' AT TIME ZONE ?) = ?",
          ^Timex.Timezone.Local.lookup(),
          ^today
        ),
      order_by: [asc: s.name],
      select: s
  end

  def by_name(name) do
    from s in __MODULE__,
      where: ilike(s.name, ^name),
      select: s
  end

  def by_current_lesson(school_id) do
    from s in __MODULE__,
      left_join: l in Lesson,
      on: l.student_id == s.id,
      where: s.school_id == ^school_id,
      group_by: s.id,
      select: %{student: s, current_lesson_number: coalesce(max(l.number), 0)},
      order_by: [asc: coalesce(max(l.number), 0)]
  end

  def search(text) do
    from s in __MODULE__,
      where: ilike(s.name, ^("%" <> text <> "%")),
      order_by: [asc: s.name],
      select: s
  end

  def add_lesson(changeset) do
    existing = Ecto.Changeset.get_field(changeset, :lessons)

    Ecto.Changeset.put_assoc(
      changeset,
      :lessons,
      existing ++ [%{completed_at: Timex.now() |> Timex.to_date()}]
    )
  end

  def remove_lesson(changeset, index) do
    existing = Ecto.Changeset.get_field(changeset, :lessons)
    {to_delete, rest} = List.pop_at(existing, index)

    new_lessons =
      if Ecto.Changeset.change(to_delete).data.id do
        List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
      else
        rest
      end

    Ecto.Changeset.put_assoc(changeset, :lessons, new_lessons)
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
