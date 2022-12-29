defmodule GameoflifeWeb.WorldLive do
  use GameoflifeWeb, :live_view

  alias Gameoflife.Events.{Dead, Off, On, Tick, Tock}

  defp id(n) do
    for _ <- 1..n, into: "", do: <<Enum.at('0123456789', :crypto.rand_uniform(0, 10))>>
  end

  def mount(%{"id" => id}, _args, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Gameoflife.PubSub, "world:#{id}")
    end

    {:ok, _} =
      GameoflifeWeb.Presence.track(self(), "users", id(12), %{
        world_id: id,
        online_at: DateTime.utc_now()
      })

    world = Gameoflife.Cell.state(id, 1, 1).world
    grid = Map.new(for i <- 0..(world.rows - 1), j <- 0..(world.columns - 1), do: {{i, j}, :off})

    {:ok, assign(socket, t: nil, id: id, world: world, grid: grid, buffer: %{})}
  end

  def handle_info(%Tick{}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Tock{t: t}, %{assigns: %{grid: grid, buffer: buffer}} = socket) do
    {:noreply, assign(socket, t: t, grid: Map.merge(grid, buffer), buffer: %{})}
  end

  def handle_info(%On{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :on))}
  end

  def handle_info(%Off{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :off))}
  end

  def handle_info(%Dead{x: x, y: y}, %{assigns: %{buffer: buffer}} = socket) do
    {:noreply, assign(socket, buffer: Map.put(buffer, {x, y}, :dead))}
  end

  def handle_event("stop", _params, socket) do
    Gameoflife.Supervisor.stop_worlds()
    {:noreply, socket}
  end
end
