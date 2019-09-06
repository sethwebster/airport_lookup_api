defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller
  
  defp filter(data, filters) do
    filters = sanitize_filters(filters) 
    |> parse_filters
    |> apply_filters(data)
    IO.puts "Done"
    IO.puts inspect filters
    data
  end

  defp apply_filters(filters, data) do
    Enum.filter(data, fn item -> 
      Enum.find(filters, fn filter -> 
        [key, value, func] = filter
        func.(key, value, item)
      end)
    end)
  end

  defp sanitize_filters(filters) do
    raw = String.split(filters, ["[","]",","])
    |> Enum.filter(fn v -> String.length(v) > 0 end)
    |> Enum.uniq
  end
  
  defp parse_filters(filters) do
    operators = [
      "!=": fn k, v, data ->
        data[k] != v
      end,
      "=": fn k, v, data -> 
        data[k] == v
      end
    ]
    Enum.map(filters, fn item -> 
      operator = Enum.find(operators, fn {k, _} -> String.contains?(item, "#{k}") end)
      {op, func} = operator
      [key, value] = String.split(item, "#{op}")
      %{
        key: key,
        value: value,
        func: func
      }
    end)
  end

  def index(conn, %{"name"=>name, "filters"=>filters}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(name) >= 2) do
      data = AirportLookupApi.AirportData.search(["name"], String.upcase(name))
      json(conn, %{data: filter(data, filters)})
    else
      json(conn, %{error: "Input for `name` requires at least two characters", data: []})
    end
  end

  def index(conn, %{"city"=>city, "filters"=>filters}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(city) >= 2) do
      data = AirportLookupApi.AirportData.search(["city"], String.upcase(city))
      json(conn, %{data: filter(data, filters)})
    else
      json(conn, %{error: "Input for `name` requires at least two characters", data: []})
    end
  end

  def index(conn, %{"search"=>search}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(search) >= 2) do
      data = AirportLookupApi.AirportData.search(["city","name"], String.upcase(search))
      json(conn, %{data: data})
    else
      json(conn, %{error: "Input for `search` requires at least two characters", data: []})
    end
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
