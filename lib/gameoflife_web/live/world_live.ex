defmodule GameoflifeWeb.WorldLive do
  @moduledoc false

  use GameoflifeWeb, :live_view

  alias Gameoflife.Commands.ChangeGridSize
  alias Gameoflife.Events.{Alive, Crashed, Dead, Tick, Tock}
  alias Gameoflife.Monitoring.WorldMonitor
  alias Gameoflife.World

  @impl true
  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      GameoflifeWeb.PubSub.subscribe("world:in:#{id}")
    end

    user_id = for _ <- 1..12, into: "", do: <<Enum.at(~c"0123456789", :rand.uniform(10) - 1)>>
    :ok = GameoflifeWeb.Presence.follow("users", user_id, %{world_id: id})

    case GameoflifeWeb.Presence.presence("worlds", id) do
      nil ->
        socket
        |> put_flash(:error, "World #{id} does not exist")
        |> push_navigate(to: "/")
        |> then(fn socket -> {:ok, socket} end)

      %{world: world} ->
        Gameoflife.state(world)

        socket
        |> assign(:t, nil)
        |> assign(:id, id)
        |> assign(:world, world)
        |> assign(:alive, 0)
        |> assign(:stats, %{alive: 0, messages: 0, size: 0})
        |> assign(:grid, World.empty_grid(world))
        |> assign(:buffer, %{})
        |> then(fn socket -> {:ok, socket} end)
    end
  end

  @impl true
  def handle_info(%Tick{}, socket) do
    {:noreply, socket}
  end

  def handle_info(
        %Tock{t: t},
        %{assigns: %{world: world, alive: alive, grid: grid, buffer: buffer}} = socket
      ) do
    socket
    |> assign(:t, t)
    |> assign(:alive, 0)
    |> assign(:stats, WorldMonitor.counter(world, alive))
    |> assign(:grid, Map.merge(grid, buffer))
    |> assign(:buffer, %{})
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_info(%Alive{x: x, y: y}, %{assigns: %{buffer: buffer, alive: alive}} = socket) do
    {:noreply, assign(socket, alive: alive + 1, buffer: Map.put(buffer, {x, y}, :a))}
  end

  def handle_info(%Dead{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :d))}
  end

  def handle_info(%Crashed{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :c))}
  end

  @impl true
  def handle_event("stop", _params, %{assigns: %{world: world}} = socket) do
    socket
    |> tap(fn _ -> Gameoflife.WorldSupervisor.stop_world(world.id) end)
    |> tap(fn _ -> GameoflifeWeb.PubSub.broadcast("worlds", world) end)
    |> push_navigate(to: "/")
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event(event, _params, %{assigns: %{world: world}} = socket) do
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
