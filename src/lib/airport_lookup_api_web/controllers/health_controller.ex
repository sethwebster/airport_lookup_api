defmodule AirportLookupApiWeb.HealthController do
  use AirportLookupApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: :ok})
  end
end
