defmodule GameoflifeWeb.StartController do
  use GameoflifeWeb, :controller

  def index(conn, _params) do
    count = Gameoflife.Supervisor.count_worlds()
    worlds = Gameoflife.Supervisor.list_worlds()
    nodes = Node.list()

    render(conn, "index.html", token: get_csrf_token(), count: count, worlds: worlds, nodes: nodes)
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
