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
    with {:ok, world} <- Gameoflife.new(String.to_integer(rows), String.to_integer(real_time)),
         :ok <- GameoflifeWeb.PubSub.broadcast("worlds", world) do
      socket
      |> push_navigate(to: ~p"/world/#{world}")
      |> then(fn socket -> {:noreply, socket} end)
    else
      _ ->
        socket
        |> put_flash(:error, "World could not be created")
        |> push_navigate(to: "/")
        |> then(fn socket -> {:noreply, socket} end)
    end
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
