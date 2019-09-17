use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :airport_lookup_api, AirportLookupApiWeb.Endpoint,
  secret_key_base: "ChossFcaZrZ98bP2gvFQWJRByg/Dlnhd1icrQhVgkjE3R7r11jgH4UR91up6Qsy0"

# Configure your database
# config :airport_lookup_api, AirportLookupApi.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "airport_lookup_api_prod",
#   pool_size: 15
