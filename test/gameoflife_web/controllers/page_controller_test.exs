defmodule GameoflifeWeb.PageControllerTest do
  use GameoflifeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Start a new world"
  end
end
