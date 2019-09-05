
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
    if redis_empty?() and !is_seeding?() do
      spawn fn ->
        set_seeding true
        data() |>
          Enum.map(fn airport -> put_airport(airport) end)
        set_seeding false
      end
    end
  end

  def is_seeding? do
    Redix.command(:redix, ["GET","system/seeding"]) == "true"
  end
  def set_seeding(in_progress) do
    Redix.command(:redix, ["SET","system/seeding",in_progress])
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
    IO.puts "Storing #{icao}..."
    Redix.command(:redix, ["SET", "airports/#{icao}", Poison.encode!(data)])
  end

end

defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller

  def index(conn, params) do
    AirportLookupApi.AirportData.seed_redis
    data = AirportLookupApi.AirportData.search(String.upcase(params["icao"]))
    json(conn, %{data: data})
  end
end
