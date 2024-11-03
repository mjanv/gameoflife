defmodule GameoflifeWeb.WorldLive do
  @moduledoc false

  use GameoflifeWeb, :live_view

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.Events.Tock
  alias Gameoflife.Monitoring.WorldMonitor
  alias Gameoflife.World

  @impl true
  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      GameoflifeWeb.PubSub.subscribe("world:in:#{id}")
    end

    :ok = GameoflifeWeb.Presence.follow("users", nil, %{world_id: id})

    case GameoflifeWeb.Presence.presence("worlds", id) do
      nil ->
        socket
        |> put_flash(:error, "World #{id} does not exist (yet)")
        |> push_navigate(to: "/")
        |> then(fn socket -> {:ok, socket} end)

      %{world: world} ->
        Gameoflife.state(world)

        socket
        |> assign(:world, world)
        |> assign(:t, 0)
        |> assign(:counters, %{alive: 0})
        |> assign(:stats, %{alive: 0, messages: 0, size: 0})
        |> assign(:buffer, World.buffer())
        |> assign(:grid, World.grid(world))
        |> then(fn socket -> {:ok, socket} end)
    end
  end

  @impl true
  def handle_info(
        %Tock{t: t} = event,
        %{assigns: %{world: world, counters: counters, grid: grid, buffer: buffer}} = socket
      ) do
    socket
    |> assign(:t, t)
    |> assign(:counters, WorldMonitor.handle(counters, event))
    |> assign(:stats, WorldMonitor.counter(counters, world))
    |> assign(:grid, World.grid(grid, buffer, event))
    |> assign(:buffer, World.buffer(buffer, event))
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_info(event, %{assigns: %{buffer: buffer, counters: counters}} = socket) do
    socket
    |> assign(:counters, WorldMonitor.handle(counters, event))
    |> assign(:buffer, World.buffer(buffer, event))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("stop", _params, %{assigns: %{world: world}} = socket) do
    socket
    |> tap(fn _ -> Gameoflife.stop_world(world.id) end)
    |> tap(fn _ -> GameoflifeWeb.PubSub.broadcast("worlds", world) end)
    |> push_navigate(to: "/")
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event(event, _params, %{assigns: %{world: world}} = socket) do
    world =
      event
      |> case do
        "decrease_size" -> %ChangeGridSize{n: -1}
        "increase_size" -> %ChangeGridSize{n: 1}
      end
      |> tap(fn event -> GameoflifeWeb.PubSub.broadcast("world:out:#{world.id}", event) end)
      |> then(fn event ->
        %{world | rows: world.rows + event.n, columns: world.columns + event.n}
      end)

    socket
    |> assign(:world, world)
    |> then(fn socket -> {:noreply, socket} end)
  end
end
