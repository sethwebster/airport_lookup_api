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

  defp airport_get_command(key) do
    ["GET", key]
  end

  defp airports(keys) do
    commands = Enum.map(keys, fn k -> airport_get_command(k) end)
    {:ok, results} = Redix.pipeline(:redix, commands)
    results
    |> Enum.map(fn data -> Poison.decode!(data) end)
  end


  defp is_full_icao?(icao) do
    String.starts_with?(icao, "K")
  end
end
