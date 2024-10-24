defmodule GameoflifeWeb.PageController do
  @moduledoc false

  use GameoflifeWeb, :controller

  @doc "Renders the home page"
  @spec home(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
