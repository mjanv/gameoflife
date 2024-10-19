defmodule GameoflifeWeb.DashboardLive do
  use GameoflifeWeb, :live_view

  alias Gameoflife.Monitoring

  def mount(_params, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "worlds")
    end

    {:ok,
     assign(socket,
       form: %{},
       token: Phoenix.Controller.get_csrf_token(),
       worlds: GameoflifeWeb.Presence.worlds(),
       nodes: Monitoring.Nodes.list(),
       architecture: Monitoring.Nodes.architecture(),
       users: GameoflifeWeb.Presence.users()
     )}
  end

  def handle_event(
        "save",
        %{"rows" => rows, "real_time" => real_time},
        socket
      ) do
    {_, world} = Gameoflife.WorldServer.new(String.to_integer(rows), String.to_integer(real_time))
    GameoflifeWeb.PubSub.broadcast("worlds", world)
    {:noreply, push_navigate(socket, to: ~p"/world/#{world}")}
  end

  def handle_event("stop", _params, socket) do
    Gameoflife.stop_all_worlds()
    socket = assign(socket, :worlds, GameoflifeWeb.Presence.worlds())
    {:noreply, socket}
  end

  def handle_info(_event, socket) do
    socket = assign(socket, :worlds, GameoflifeWeb.Presence.worlds())
    {:noreply, socket}
  end
end
