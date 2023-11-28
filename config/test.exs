import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :lifetown_clinic, LifetownClinic.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "lifetown_clinic_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lifetown_clinic, LifetownClinicWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gw0Pcmt35Wl1NA+Gvf9WSH+wzrCWm9LlRYncPqelaz0KTHe3E2BXHnjM2Hph9v2O",
  server: false

# In test we don't send emails.
config :lifetown_clinic, LifetownClinic.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
