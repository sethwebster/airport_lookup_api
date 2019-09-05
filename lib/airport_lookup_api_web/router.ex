defmodule AirportLookupApiWeb.Router do
  use AirportLookupApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AirportLookupApiWeb do
    pipe_through :api

    get "/airport/", AirportController, :index
  end
end
