defmodule LifetownClinic.Student do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "students" do
    field :name, :string
    belongs_to :school, LifetownClinic.School
    has_many :lessons, LifetownClinic.Lesson

    timestamps()
  end

  def checked_in_today() do
    today = Date.utc_today()

    from s in __MODULE__,
      where: fragment("date(inserted_at) = ?", ^today),
      select: s
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
