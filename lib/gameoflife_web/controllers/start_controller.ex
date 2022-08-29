defmodule GameoflifeWeb.StartController do
  use GameoflifeWeb, :controller

  def index(conn, _params) do
    worlds = render(conn, "index.html", token: get_csrf_token())
  end

  def create(conn, %{"columns" => columns, "rows" => rows}) do
    world =
      Gameoflife.World.new(columns, rows)
      |> GameoflifeEngine.World.start_world()
      |> GameoflifeEngine.World.start_tick()

    conn
    |> put_flash(:info, "Starting world #{inspect(world.id)}")
    |> redirect(to: Routes.world_path(conn, :index, world.id))
  end
end
