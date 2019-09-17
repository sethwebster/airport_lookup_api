defmodule AirportLookupApiWeb.Router do
  use AirportLookupApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", AirportLookupApiWeb do
    pipe_through :api
    get "/airport/", AirportController, :index
    get "/health/", HealthController, :index
  end
end
