use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :airport_lookup_api, AirportLookupApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# # Configure your database
# config :airport_lookup_api, AirportLookupApi.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "airport_lookup_api_test",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox
