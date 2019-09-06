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
