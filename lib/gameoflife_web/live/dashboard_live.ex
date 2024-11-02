defmodule GameoflifeWeb.DashboardLive do
  @moduledoc false

  use GameoflifeWeb, :live_view

  alias Gameoflife.Monitoring

  @impl true
  def mount(_params, _args, socket) do
    if connected?(socket) do
      GameoflifeWeb.PubSub.subscribe("worlds")
    end

    socket
    |> assign(:form, %{})
    |> assign(:token, Phoenix.Controller.get_csrf_token())
    |> assign(:worlds, GameoflifeWeb.Presence.worlds())
    |> assign(:nodes, Monitoring.NodeMonitor.list())
    |> assign(:architectures, Monitoring.NodeMonitor.architectures())
    |> assign(:users, GameoflifeWeb.Presence.users())
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event(
        "save",
        %{"rows" => rows, "real_time" => real_time},
        socket
      ) do
    {_, world} =
      Gameoflife.WorldDynamicSupervisor.new(String.to_integer(rows), String.to_integer(real_time))

    GameoflifeWeb.PubSub.broadcast("worlds", world)
    {:noreply, push_navigate(socket, to: ~p"/world/#{world}")}
  end

  def handle_event("stop", _params, socket) do
    socket
    |> tap(fn _ -> Gameoflife.stop_all_worlds() end)
    |> assign(:worlds, GameoflifeWeb.Presence.worlds())
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(_event, socket) do
    socket
    |> assign(:worlds, GameoflifeWeb.Presence.worlds())
    |> then(fn socket -> {:noreply, socket} end)
  end
end
