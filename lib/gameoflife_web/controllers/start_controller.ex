defmodule GameoflifeWeb.StartController do
  use GameoflifeWeb, :controller

  def index(conn, _params) do
    count = GameoflifeEngine.Supervisor.count_worlds()
    worlds = GameoflifeEngine.Supervisor.list_worlds()
    nodes = Node.list()

    render(conn, "index.html", token: get_csrf_token(), count: count, worlds: worlds, nodes: nodes)
  end

  def create(conn, %{"columns" => columns, "rows" => rows}) do
    world =
      Gameoflife.World.new(String.to_integer(columns), String.to_integer(rows))
      |> GameoflifeEngine.World.start_world()
      |> GameoflifeEngine.World.start_cells()
      |> GameoflifeEngine.World.start_clock()

    conn
    |> put_flash(:info, "Starting world #{inspect(world.id)}")
    |> redirect(to: Routes.world_path(conn, :index, world.id))
  end
end
