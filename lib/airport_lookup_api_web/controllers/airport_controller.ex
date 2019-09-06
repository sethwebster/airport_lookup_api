
defmodule AirportLookupApi.AirportData.Importer do
  def data do
    path = "./data/airports.json"
    File.read!(path) |>
    Poison.decode!
  end

  def seed_redis_if_necessary do
    if redis_empty?() and !is_seeding?() do
      spawn fn ->
        set_seeding true
        send_data_to_redis()
        set_seeding false
      end
    end
  end

  defp send_data_to_redis do
    commands = data()
    |>Enum.map(fn airport -> put_airport_command(airport) end)
    Redix.pipeline(:redix, commands)
  end

  defp is_seeding? do
    Redix.command(:redix, ["GET","system/seeding"]) == "true"
  end

  defp set_seeding(in_progress) do
    Redix.command(:redix, ["SET","system/seeding",in_progress])
  end

  defp put_airport_command(airport) do
    {icao, data} = airport
    ["SET", "airports/#{icao}", Poison.encode!(data)]
  end

  defp redis_empty? do
    {:ok, airport} = Redix.command(:redix, ["GET","airports/ZZZZ"])
    if (airport) do
      false
    else
      true
    end
  end
end

defmodule AirportLookupApi.AirportData do
  def search(airport) do
    keys = keys(airport)
    airports(keys)
  end

  defp keys(icao) do
    query1 = search_key(icao)
    {:ok, keys1} = Redix.command(:redix, ["KEYS",query1])
    if is_full_icao?(icao) do
      keys1
    else
      query2 = search_key("K#{icao}")
      {:ok, keys2} = Redix.command(:redix, ["KEYS",query2])
      Enum.filter(keys1 ++ keys2, & !is_nil(&1))
    end
  end

  defp search_key(icao) do
    "#{key(icao)}*"
  end

  defp key(icao) do
    "airports/#{icao}"
  end

  defp airport(key) do
    IO.puts("Airport: #{key}")
    {:ok, data} = Redix.command(:redix, ["GET", key])
    if data do
      Poison.decode!(data)
    else
      nil
    end
  end

  defp airports(keys) do
    Enum.map(keys, fn k -> airport(k) end)
  end


  defp is_full_icao?(icao) do
    String.starts_with?(icao, "K")
  end
end

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
