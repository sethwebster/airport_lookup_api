defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller
  
  def index(conn, %{"search"=>search}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(search) >= 2) do
      data = AirportLookupApi.AirportData.search(String.upcase(search))
      json(conn, %{data: data})
    else
      json(conn, %{error: "Input for `search` requires at least two characters", data: []})
    end
    json(conn, %{data: "hit"})
  end

  def index(conn, params) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if String.length(params["icao"]) >= 2 do
      data = AirportLookupApi.AirportData.search_icao(String.upcase(params["icao"]))
      json(conn, %{data: data})
    else
      json(conn, %{error: "Input for `icao` requires at least two characters", data: []})
    end
  end
end
