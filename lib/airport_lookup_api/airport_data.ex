defmodule AirportLookupApi.AirportData do

  def search(facets, query) when is_list(facets) do
    keys = facets 
    |>Enum.map(fn facet -> keys(facet, query) end)
    |>List.flatten
    |>Enum.uniq
    IO.puts inspect keys
    airports(keys)
    |>List.flatten
    |>Enum.uniq 
  end

  def search_icao(icao) do
    keys = keys("icao", icao)
    airports(keys)
  end

  defp keys(facet, query) do
    { :ok, results } = Redix.pipeline(:redix, search_key_commands(facet, query))
    results
    |> List.flatten
    |> Enum.uniq
  end

  defp search_key_commands(facet, query) do
    Enum.map(search_keys(facet, query), fn key -> ["KEYS", key] end)
  end

  defp search_keys(facet, query) do
    if (facet == "icao" && !is_full_icao?(query)) do
      [search_key(facet, query), search_key(facet, "K#{query}")]
    else
      [search_key(facet, query)]
    end
  end

  defp search_key(facet, query) do
    "#{key(facet, query)}*"
  end

  defp key(facet, query) do
    "airports/#{facet}/#{query}"
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
