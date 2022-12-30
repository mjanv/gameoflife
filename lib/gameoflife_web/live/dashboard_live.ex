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

  def handle_event(
        "save",
        %{"rows" => rows, "real_time" => real_time, "failure" => failure} = args,
        socket
      ) do
    {_, world} =
      Gameoflife.World.new(
        String.to_integer(rows),
        String.to_integer(real_time),
        String.to_integer(failure)
      )

    Phoenix.PubSub.broadcast(Gameoflife.PubSub, "worlds", world)

    socket =
      socket
      |> push_redirect(to: Routes.world_path(socket, :index, world.id))

    {:noreply, socket}
  end

  def handle_info(event, socket) do
    socket = assign(socket, :worlds, GameoflifeWeb.Presence.worlds())
    {:noreply, socket}
  end

  def handle_event("stop", _params, socket) do
    Gameoflife.Supervisor.stop_worlds()
    socket = assign(socket, :worlds, GameoflifeWeb.Presence.worlds())
    {:noreply, socket}
  end
end
