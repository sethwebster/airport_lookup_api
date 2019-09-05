
defmodule AirportLookupApi.AirportData do

  def keys(airport) do
    query1 = "airports/#{airport}*"
    {:ok, keys1} = Redix.command(:redix, ["KEYS",query1])
    if is_full_icao?(airport) do
      keys1
    else
      query2 = "airports/K#{airport}*"
      {:ok, keys2} = Redix.command(:redix, ["KEYS",query2])
      Enum.filter(keys1 ++ keys2, & !is_nil(&1))
    end
  end

  def airport(key) do
    {:ok, data} = Redix.command(:redix, ["GET", key])
    if data do
      Poison.decode!(data)
    else
      nil
    end
  end

  def airports(keys) do
    Enum.map(keys, fn k -> airport(k) end)
  end

  def search(airport) do
    keys = keys(airport)
    airports(keys)
  end

  def data do
    path = "./data/airports.json"
    File.read!(path) |>
    Poison.decode!
  end

  defp is_full_icao?(icao) do
    String.starts_with?(icao, "K")
  end

  def seed_redis do
    if redis_empty?() do
      data() |>
        Enum.map(fn airport -> put_airport(airport) end)
    end
  end

  defp redis_empty? do
    airport = airport("airports/ZZZZ")
    if (airport) do
      false
    else
      true
    end
  end

  def put_airport(airport) do
    {icao, data} = airport
    Redix.command(:redix, ["SET", "airports/#{icao}", Poison.encode!(data)])
  end

end

defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller

  def index(conn, params) do
    AirportLookupApi.AirportData.seed_redis
    data = AirportLookupApi.AirportData.search(params["icao"])
    json(conn, %{data: data})
  end
end
