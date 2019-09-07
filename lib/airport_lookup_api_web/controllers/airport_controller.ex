defmodule AirportLookupApiWeb.AirportController do
  use AirportLookupApiWeb, :controller

  defp filter(data, filters) do
    filtered = sanitize_filters(filters)
    |> parse_filters
    |> apply_filters(data)
    filtered
  end

  defp apply_filters(filters, data) do
    Enum.filter(data, fn item ->
      filter_results = Enum.map(filters, fn filter ->
        %{:key => key, :value => value, :func => func} = filter
        func.(key, value, item)
      end)
      Enum.all?(filter_results, fn res -> res end)
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
      end,
      "->": fn k, v, data ->
        String.split(v,["|"])
        |> Enum.find(fn opt -> opt == data[k] end)
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

  def index(conn, %{"name"=>name, "filters"=> filters }) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(name) >= 2) do
      data = AirportLookupApi.AirportData.search(["name"], String.upcase(name))
      json(conn, %{data: filter(data, filters)})
    else
      json(conn, %{error: "Input for `name` requires at least two characters", data: []})
    end
  end

  def index(conn, %{ "name" => name } = params) do
    index(conn, %{"name" => name, "filters" => "[]"})
  end

  def index(conn, %{"city"=>city, "filters"=>filters}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if (String.length(city) >= 2) do
      data = AirportLookupApi.AirportData.search(["city"], String.upcase(city))
      json(conn, %{data: filter(data, filters)})
    else
      json(conn, %{error: "Input for `city` requires at least two characters", data: []})
    end
  end

  def index(conn, %{ "city" => city } = params) do
    index(conn, %{"city" => city, "filters" => "[]"})
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

  def index(conn, %{"icao" => icao}) do
    AirportLookupApi.AirportData.Importer.seed_redis_if_necessary
    if String.length(icao) >= 2 do
      data = AirportLookupApi.AirportData.search_icao(String.upcase(icao))
      json(conn, %{data: data})
    else
      json(conn, %{error: "Input for `icao` requires at least two characters", data: []})
    end
  end
end
