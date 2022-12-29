defmodule GameoflifeWeb.DashboardLive do
  use GameoflifeWeb, :live_view

  def mount(_params, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "worlds")
    end

    {:ok,
     assign(socket,
       token: Phoenix.Controller.get_csrf_token(),
       worlds: GameoflifeWeb.Presence.worlds(),
       nodes: [Node.self()] ++ Node.list(),
       users: GameoflifeWeb.Presence.users()
     )}
  end

  def handle_event("save", %{"rows" => rows, "real_time" => real_time, "failure" => failure}, socket) do
    world =
      rows
      |> String.to_integer()
      |> Gameoflife.World.new()
      |> Gameoflife.World.start_world()
      |> Gameoflife.World.start_cells(IO.inspect(String.to_integer(failure), label: "?"))
      |> Gameoflife.World.start_clock(String.to_integer(real_time))

    socket = socket
    |> push_redirect(to: Routes.world_path(socket, :index, world.id))

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "worlds", :ok)

    {:noreply, socket}
  end
end
