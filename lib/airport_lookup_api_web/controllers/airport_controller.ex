
defmodule AirportLookupApi.AirportData do
  def search(airport) do
    IO.puts airport
    IO.puts inspect data
  end

  def data do
    path = "./data/airports.json"
    File.read!(path) |>
      Poison.decode!
  end

end

defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller

  def index(conn, params) do
    data = AirportLookupApi.AirportData.search(params["icao"])
    json(conn, %{data: data})
  end
end
