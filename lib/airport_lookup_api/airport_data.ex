defmodule AirportLookupApi.AirportData do
  def search(airport) do
    keys = keys(airport)
    airports(keys)
  end

  defp keys(icao) do
    { :ok, results } = Redix.pipeline(:redix, search_key_commands(icao))
    results
    |> List.flatten
    |> Enum.uniq
  end

  defp search_key_commands(icao) do
    Enum.map(search_keys(icao), fn key -> ["KEYS", key] end)
  end

  defp search_keys(icao) do
    if (!is_full_icao?(icao)) do
      [search_key(icao), search_key("K#{icao}")]
    else
      [search_key(icao)]
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

  defp airports([]) do
    []
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
