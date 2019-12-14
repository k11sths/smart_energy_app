use Mix.Config

# Configure your database
config :smart_energy, SmartEnergy.Repo,
  username: "postgres",
  password: "postgres",
  database: "smart_energy_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smart_energy, SmartEnergyWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
