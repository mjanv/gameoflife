defmodule GameoflifeWeb.StartController do
  use GameoflifeWeb, :controller

  def index(conn, _params) do
    worlds = GameoflifeWeb.Presence.worlds()
    nodes = [Node.self()] ++ Node.list()
    users = GameoflifeWeb.Presence.users()

    render(conn, "index.html",
      token: get_csrf_token(),
      worlds: worlds,
      nodes: nodes,
      users: users
    )
  end

  def create(conn, %{"rows" => rows}) do
    world =
      rows
      |> String.to_integer()
      |> Gameoflife.World.new()
      |> Gameoflife.World.start_world()
      |> Gameoflife.World.start_cells()
      |> Gameoflife.World.start_clock()

    conn
    |> put_flash(:info, "Starting world #{inspect(world.id)}")
    |> redirect(to: Routes.world_path(conn, :index, world.id))
  end
end
