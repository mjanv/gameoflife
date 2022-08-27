defmodule GameoflifeWeb.PageController do
  use GameoflifeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
