defmodule LifetownClinic.Repo do
  use Ecto.Repo,
    otp_app: :lifetown_clinic,
    adapter: Ecto.Adapters.Postgres
end
