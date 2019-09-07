defmodule AirportLookupApi.AirportData.Importer do
  @airports_prefix "airports/"
  @icao_index "icao/"
  @name_index "name/"
  @city_index "city/"

  def data do
    path = "./data/airports.json"
    File.read!(path) |>
    Poison.decode!
  end

  def seed_redis_if_necessary do
    if redis_empty?() and !is_seeding?() do
      spawn fn ->
        IO.puts "Seeding Data..."
        set_seeding true
        send_data_to_redis()
        set_seeding false
        IO.puts "Data seeding complete..."
      end
    end
  end

  defp send_data_to_redis do
    airports = data()

    icao_commands = airports
    #|>Enum.take(10000)
    |>Enum.map(fn airport -> put_airport_commands(airport) end)
    |>flatten_commands

    city_commands = airports
    #|>Enum.take(10000)
    |>airports_by_facet("municipality")
    |>Enum.map(fn {key, value} -> set_facet_command("city", key, value) end)

    name_commands = airports
    #|>Enum.take(10000)
    |>airports_by_facet("name")
    |>Enum.map(fn {key, value} -> set_facet_command("name", key, value) end)

    commands = icao_commands ++ city_commands ++ name_commands

    IO.puts "Sending #{length(commands)} to Redix..."
    {:ok} = stream_commands_to_redis(commands, 0, 5000)
    IO.puts "Complete."
  end

  defp stream_commands_to_redis(commands, start, size) when start >= length(commands) do
    IO.puts("Done.")
    {:ok}
  end

  defp stream_commands_to_redis(commands, start, size) do
    IO.puts("Sending #{size} records from #{start}...")
    {:ok, response} = Redix.pipeline(:redix, Enum.slice(commands, start, size))
    stream_commands_to_redis(commands, start + size, size)
  end



  defp airports_by_facet(data, facet) do
    Enum.reduce(data, %{}, fn curr, acc ->
      { icao, obj } = curr
      facet = obj[facet]
      existing = Map.get(acc, facet) || []
      acc = Map.put(acc, facet, existing ++ [obj])
    end)
  end

  defp flatten_commands(commands) do
    Enum.reduce(commands, [], fn curr, acc ->
      acc ++ curr
    end)
  end

  defp is_seeding? do
    Redix.command(:redix, ["GET","system/seeding"]) == "true"
  end

  defp set_seeding(in_progress) do
    Redix.command(:redix, ["SET","system/seeding",in_progress])
  end

  defp set_facet_command(facet, key, value) do
    ["SET", "#{@airports_prefix}#{facet}/#{String.upcase(key)}", Poison.encode!(value)]
  end

  defp put_airport_commands(airport) do
    {icao, data} = airport
    obj = Poison.encode!(data)
    %{"name" => name, "municipality" => city} = data
    [
      ["SET", "#{@airports_prefix}#{@icao_index}#{icao}", obj]
    ]
  end

  defp redis_empty? do
    {:ok, airport} = Redix.command(:redix, ["GET","#{@airports_prefix}#{@icao_index}ZZZZ"])
    if (airport) do
      false
    else
      true
    end
  end
end
