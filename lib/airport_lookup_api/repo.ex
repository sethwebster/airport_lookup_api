defmodule AirportLookupApi.Repo do
  use Ecto.Repo,
    otp_app: :airport_lookup_api,
    adapter: Ecto.Adapters.Postgres
end
