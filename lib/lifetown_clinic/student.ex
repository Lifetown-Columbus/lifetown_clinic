defmodule LifetownClinic.Student do
  use Ecto.Schema
  schema "students" do
    field :name, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end
end
