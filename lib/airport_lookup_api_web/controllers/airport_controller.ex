defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller

  def index(conn, params) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if String.length(params["icao"]) >= 2 do
      data = AirportLookupApi.AirportData.search(String.upcase(params["icao"]))
      json(conn, %{data: data})
    else
      json(conn, %{error: "Input for `icao` requires at least two characters", data: []})
    end
  end
end
