defmodule GameoflifeWeb.WorldLive do
  use GameoflifeWeb, :live_view

  alias Gameoflife.Events.{Tick, Tock, On, Off}

  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:#{id}")
    end

    world = Gameoflife.Cell.state(id, 1, 1).world
    grid = Map.new(for i <- 0..(world.rows - 1), j <- 0..(world.columns - 1), do: {{i, j}, false})

    {:ok, assign(socket, t: nil, id: id, world: world, grid: grid, buffer: %{})}
  end

  def handle_info(%Tick{}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Tock{t: t}, %{assigns: %{grid: grid, buffer: buffer}} = socket) do
    {:noreply, assign(socket, t: t, grid: Map.merge(grid, buffer), buffer: %{})}
  end

  def handle_info(%On{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, true))}
  end

  def handle_info(%Off{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, false))}
  end

  def handle_event("stop", _params, socket) do
    GameoflifeEngine.Supervisor.stop_worlds()
    {:noreply, socket}
  end
end
